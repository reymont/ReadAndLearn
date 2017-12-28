namerctlBaseURL = "http://10.110.251.97:4180"
    
node {
    def currentVersion = getCurrentVersion()
    def newVersion = getNextVersion(currentVersion)
    def frontendIp = kubectl("get svc l5d -o jsonpath=\"{.status.loadBalancer.ingress[0].*}\"").trim()
    def originalDst = getDst(getDtab())

    stage("clone") {
        git url: gitRepo + '.git', branch: gitBranch
    }

    stage("deploy") {
        //signalDeploy()
        def targetWorld = readFile('k8s-daemonset/helloworld/world.txt').trim()
        updateConfig(targetWorld, newVersion)
        def created = kubectl("apply -f hello-world.yml")
        echo "${created}"
        sleep 5 // give the instance some time to start
    }

    stage("integration testing") {
        def dtabOverride = "l5d-dtab: /host/world => /tmp/${newVersion}"
        runIntegrationTests(frontendIp, dtabOverride)
        try {
            input(
                message: "Integration tests successful!\nYou can reach the service with:\ncurl -H \'${dtabOverride}\' ${frontendIp}",
                ok: "OK, done with manual testing"
            )
        } catch(err) {
            revert(originalDst, newVersion)
            throw err
        }
    }

    stage("shift traffic (10%)") {
        setDst(getDtab(), "1 * /tmp/${newVersion} & 9 * /tmp/${currentVersion}")
        try {
            input(
                message: "Shifting 10% of traffic. To view, open:\nhttp://${frontendIp}:9990",
                ok: "OK, success rates look stable"
            )
        } catch(err) {
            revert(originalDst, newVersion)
            throw err
        }
    }

    stage("shift traffic (100%)") {
        setDst(getDtab(), "/tmp/${newVersion} | /tmp/${currentVersion}")
        try {
            input(
                message: "Deploy finished. Ready to cleanup?",
                ok: "OK, everything looks good"
            )
        } catch(err) {
            revert(originalDst, newVersion)
            throw err
        }
    }

    stage("cleanup") {
        setDst(getDtab(), "/srv/${newVersion}")
        sleep 5 // wait for dtab change to propagate
        kubectl("delete svc ${currentVersion}")
        kubectl("delete rc ${currentVersion}")
    }
}

def kubectl(cmd) {
    return sh(script: "kubectl --namespace=${k8sNamespace} ${cmd}", returnStdout: true)
}

def getDtab() {
    return sh(script: "NAMERCTL_BASE_URL=" + namerctlBaseURL + " namerctl dtab get ${namerdNamespace} --base-url http://10.110.251.97:4180 --json", returnStdout: true)
}

def deleteDtab() {
    return sh(script: "namerctl dtab delete internal --base-url http://10.110.251.97:4180", returnStdout: true)
}

def setDtab(dtab) {
    writeFile file: namerdNamespace + ".dtab", text: dtab
    return sh(script: "NAMERCTL_BASE_URL=" + namerctlBaseURL + " namerctl dtab update ${namerdNamespace} ${namerdNamespace}.dtab --base-url http://10.110.251.97:4180 --json", returnStdout: true)
}

def getDst(jsonResp) {
    def json = new groovy.json.JsonSlurper().parseText(jsonResp)
    for (dentry in json.dtab) {
        if (dentry.prefix == "/host/world") {
            return dentry.dst
        }
    }
}

def setDst(jsonResp, dst) {
    def json = new groovy.json.JsonSlurper().parseText(jsonResp)
    for (dentry in json.dtab) {
        if (dentry.prefix == "/host/world") {
            dentry.dst = dst
        }
    }
    def str = groovy.json.JsonOutput.toJson(json)
    json = null // must clear json obj from scope before calling setDtab
    return setDtab(str)
}

def signalDeploy() {
    def jsonResp = getDtab()
	//deleteDtab()
    def dst = getDst(jsonResp)
    if (dst =~ /^\/tmp/) {
        error "dtab is already marked as being deployed!"
    }
    def resp = setDst(jsonResp, dst.replace("/srv", "/tmp"))
    echo "${resp}"
}

def getCurrentVersion() {
    def jsonResp = kubectl("get svc -o json")
    def json = new groovy.json.JsonSlurper().parseText(jsonResp)
    for (svc in json.items) {
        if (svc.metadata.name =~ /^world/) {
            return svc.metadata.name
        }
    }
}

def getNextVersion(currentVersion) {
    def versionNum = currentVersion.replace("world-v", "").toInteger()
    return "world-v${versionNum + 1}"
}

def updateConfig(targetWorld, newVersion) {
    def config = readFile('k8s-daemonset/k8s/hello-world.yml')
        .replaceAll("world-v1", newVersion)
        .replaceAll("value: world", "value: ${targetWorld}")
    writeFile file: "hello-world.yml", text: config
}

def runIntegrationTests(frontendIp, dtabOverride) {
    def resp = sh(script: "curl -sL -w '%{http_code}' -o /dev/null  -H '${dtabOverride}' ${frontendIp} 2>&1", returnStdout: true).trim()
    if (resp != "200") {
        error "could not reach new service"
    }
}

def revert(originalDst, newVersion) {
    echo "reverting traffic back to ${originalDst}"
    setDst(getDtab(), originalDst)
    kubectl("delete svc ${newVersion}")
    kubectl("delete rc ${newVersion}")
}