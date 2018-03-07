## Tips for the Certified Kubernetes Administrator (CKA) Exam  

### Exam Details
-  You can take the CKA certification exam from any qualifying computer, anywhere there is
internet, almost any time. No need to go to a test center. (see Hardware Compatibility Check
below)
-  The online exam consists of a set of 24 performance-based items (problems) to be solved on the
command line.
- The exam is expected to take 2-3 hours to complete.
### What You Need For Your Exam
- Make sure your ID is ready for the exam. You may use any current, non-expired government ID
that has your photo and full name in the Latin alphabet
- Exams are delivered online and closely monitored by proctors via webcam, audio, and remote
screen viewing.
- Candidates must provide their own front-end hardware to take exams, including a computer with:
  - Chrome or Chromium browser
  - reliable internet access
  - webcam
  - microphone  
  
### Hardware Compatibility Check
- Candidates should run the compatibility check tool provided by the Exam Proctoring Partner to
verify that their hardware meets the minimum requirements.
- The tool is located at https://www.examslocal.com/ScheduleExam/Home/CompatibilityCheck.
Select “Linux Foundation” as the Exam Sponsor and “CKA” as the Exam.
- At this time, only Chrome and Chromium browsers are supported and candidates need a
functioning webcam so that the proctor can see them.
### Exam Results
- Results will be emailed 36 hours from the time that the exam was completed.
- Results will also be made available on My Portal.
### Rules during exam
- Candidates may browse for and use technical documentation, including downloading and
installing templates and other technical assets. An example of a good resource is,
https://kubernetes.io/docs/reference/.
- Candidates are not allowed to access exam-specific assets, meaning those created by (or with
the assistance of) those with prior exposure to the exam content and for the purpose of providing
specific assistance to a candidate taking the CKA exam.
- Candidates may use the Notepad feature accessible in the top menu bar of the exam console
(notes entered here will not be retained or accessible after the exam has ended)
- Candidates are not allowed scratch paper, food or beverages during the exam however, you may
request a bathroom break or to get a drink (the exam timer keeps running).
- If you need food or beverage accommodations for medical purposes, please contact
certificationsupport@cncf.io a minimum of 2 weeks before the date of your exam.
- Please see the CKA Candidate Handbook for additional information covering policies and
procedures.
- Answers to Frequently Asked Questions (FAQ) can be found here
- If you cannot find an answer to your question in the Candidate Handbook or FAQ, you may
contact Customer Support at certificationsupport@cncf.io
### Technical Instructions
You may access these instructions at any time while taking the exam by typing 'man cka_exam'.
1. Root privileges can be obtained by running *'sudo −i'*.
2. Rebooting of your server IS permitted at anytime.
3. Do not stop or tamper with the gateone process as this will END YOUR EXAM SESSION.
4. Do not block incoming ports 8080/tcp, 4505/tcp and 4506/tcp. This includes firewall rules that are
found within the distribution's default firewall configuration files as well as interactive firewall
commands.
5. Use Ctrl+Alt+W instead of Ctrl+W.
5.1. Ctrl+W is a keyboard shortcut that will close the current tab in Google Chrome.
6. Ctrl+C & and Ctrl+V are not supported in your exam terminal, nor is copy and pasting large
amounts of text. To copy and paste limited amounts of text (1−2 lines) please use;
6.1. For Linux: select text for copy and middle button for paste (or both left and right
simultaneously if you have no middle button).
6.2. For Mac: ⌘+C to copy and ⌘+V to paste.
6.3. For Windows: Ctrl+Insert to copy and Shift+Insert to paste.
6.4. In addition, you might find it helpful to use the Notepad (see top menu under 'Exam
Controls') to manipulate text before pasting to the command line.
7. Installation of services and applications included in this exam may require modification of system
security policies to successfully complete.
8. Only a single terminal console is available during the exam. Terminal multiplexers such as GNU
Screen and tmux can be used to create virtual consoles.
### General Notes
- The first exam item contains instructions and notes on the exam environment.
- Ensure you read this item thoroughly before commencing your exam.
- You can use the question navigation features to return to the first exam item at any time.
Tips for the Certified Kubernetes Administrator (CKA) Exam ​Version 1.5​ Updated January 15, 2018 page 2
### CKA Environment
- Each question on this exam must be completed on a designated cluster/configuration context.
- To minimize switching, the questions are grouped so that all questions on a given cluster appear
consecutively.
- There are six clusters that comprise the exam environment, made up of varying numbers of
containers, as follows:

|Cluster | Members  | CNI | Description
| :----- | ------:| ----:| :-------: |
|k8s  |1  etcd, 1  master, 2  worker | flannel  | k8s cluster|
|hk8s |1  etcd, 1  master, 2  worker | calico  | k8s cluster|
|bk8s |1  etcd, 1  master, 1 worker | flannel | k8s cluster|
|wk8s |1  etcd, 1  master, 2 worker | flannel | k8s cluster|
|ek8s |1  etcd, 1  master, 2 worker | flannel | k8s cluster|
|ik8s |1 etcd, 1 master, 1 base node  | loopback |k8s cluster − missing worker node|

At the start of each question you'll be provided with the command to ensure you are on the correct cluster e.g.,  

Set configuration context: *$ kubectl config use-context k8s*  

Nodes comprising each cluster can be reached via ssh, using a command such as the following:
*$ ssh k8s-node-0*
Elevated privileges can be assumed on any node with the following command:
*$ sudo -i*
When you have finished working on a node, you should return to the base node (with hostname node-1)
before attempting any further questions. *Nested−ssh* is not supported.
You can use kubectl and the appropriate context to work on any cluster from the base node. When
connected to a cluster member via ssh, you will only be able to work on that particular cluster via kubectl.
Further instructions for connecting to cluster nodes will be provided in the appropriate questions, and
certain hints may be provided where required on specific items.
### Important Considerations
1. The environment is currently running Kubernetes v1.9.1.
2. You are free to search for exam−relevant documentation on the Internet at any time during the
exam, in a separate browser tab. Please note, that your exam session is being monitored live,
and recorded, and can be reviewed after the exam has been completed.  


&copy;Tips for the Certified Kubernetes Administrator (CKA) Exam ​Version 1.5​ Updated January 15, 2018

