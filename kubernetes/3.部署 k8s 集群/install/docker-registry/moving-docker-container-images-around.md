
* [Moving Docker Containers and Images Around ](https://blog.giantswarm.io/moving-docker-container-images-around/)

Giant Swarm runs a Docker container registry at registry.giantswarm.io as a convenience feature for users that have signed up for the private alpha test. When you signup for an account, you also get an account in the registry we host. You can use this private registry to store container images for the services you run on Giant Swarm.

One feature we don’t yet support is the ability to fetch images from remote private registries such as those hosted by Docker Hub, CoreOS’s Quay.io, or Google Container Registry. Public images stored on those services work just fine with us, and we’re planning on adding support for remote private registries in the near future.



While working with a potential customer, I’ve found myself needing to run images on Giant Swarm which are stored in a private repository hosted on Docker Hub. After floundering around a bit, I finally figured out the solution and figured I’d share it up here.

Moving Images Repo to Repo

If you simply want to move images from one repository to another, the easiest way to achieve this is by using the docker tag and docker push methods. We’ll start by pulling an image from Docker Hub, the default repository use by docker:

$ docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
d3a1f33e8a5a: Pull complete
c22013c84729: Pull complete
d74508fb6632: Pull complete
91e54dfb1179: Already exists
library/ubuntu:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
Digest: sha256:fde8a8814702c18bb1f39b3bd91a2f82a8e428b1b4e39d1963c5d14418da8fba
Status: Downloaded newer image for ubuntu:latest
Next, we tag the image with the desired destination repository:

$ docker tag ubuntu registry.giantswarm.io/kord/ubuntu
Finally, we push the image to the new registry:

$ docker push registry.giantswarm.io/kord/ubuntu
The push refers to a repository [registry.giantswarm.io/kord/ubuntu] (len: 1)
Sending image list
Pushing repository registry.giantswarm.io/kord/ubuntu (1 tags)
d3a1f33e8a5a: Image successfully pushed
c22013c84729: Image successfully pushed
d74508fb6632: Image successfully pushed
91e54dfb1179: Image successfully pushed
Pushing tag for rev [91e54dfb1179] on {https://registry.giantswarm.io/v1/repositories/kord/ubuntu/tags/latest}
Note: You will need to be logged into the other registry before pushing to a private repo!

Moving Images from Host to Host

In the example above, moving an image from one registry to another requires pulling and pushing images via the Internets. If you simply need to move an image from one host to the other, as is the case with sharing an image with someone in the office, you can achieve similar results without the overhead of uploading and downloading the image.

Export vs. Save

Docker supports two different types of methods for saving container images to a single tarball:

docker export - saves a container’s running or paused instance to a file
docker save - saves a non-running container image to a file
Using Export

Let’s take a look at the docker export method first. We’ll start by having Bob pulling an Ubuntu image down from Docker Hub:

$ docker pull ubuntu
<snip>
Status: Downloaded newer image for ubuntu:latest
Now Bob runs the instance in interactive mode and adds a file named this to the root directory:

$ docker run -t -i ubuntu /bin/bash
root@defc757ce803:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@defc757ce803:/# touch this
root@defc757ce803:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  this  tmp  usr  var
If Bob exits this prompt, his container will be destroyed. So, in another shell, Bob runs the docker export command to export the instance’s image:

$ # output truncated slightly
$ docker ps
CONTAINER ID        IMAGE               COMMAND         
defc757ce803        ubuntu              "/bin/bash"
$ docker export defc | gzip > ubuntu.tar.gz
$ ls -lah ubuntu.tar.gz
-rw-r--r--    1 bob  staff    63M Aug 28 13:56 ubuntu.tar.gz
We can now have Bob upload the ubuntu.tar.gz file on his computer to Alice’s computer using sneakernet. Once Bob finishes, Alice can use a docker import on the image and give it a new tag in the process:

$ ls -lah ubuntu.tar.gz
-rw-r--r--    1 alice  staff    63M Aug 28 13:56 ubuntu.tar.gz
$ gzcat ubuntu.tar.gz | docker import - ubuntu-alice
e7a0d776251fb5c7d61a6aa481f1aa8cf6f8c2936e893030ac481ff4499ec129
Now Alice can run the container and verify Bob’s this file is intact:

$ docker run -t -i ubuntu-alice /bin/bash
root@3f7f57eb9959:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  this  tmp  usr  var
Using Save

Alternately, Bob could have simply done a docker save on the Ubuntu image to give Alice a copy of the container’s image, which she could use without Bob’s modifications:

$ docker save ubuntu | gzip > ubuntu-golden.tar.gz
Alice would then take that copy and load it, instead of doing an import :

$ gzcat ubuntu-golden.tar.gz | docker load
Now Alice runs the container and notes that Bob’s this file is not there:

$ docker run -i -t ubuntu /bin/bash
root@e11b3abb67de:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
I will note here if Alice does a docker import - ubuntu instead of docker load, that docker will store the image with zero complaints. Docker will even try to start an imported instance which was saved with docker export. It will just fail to run anything in the container when it does so.

Increase boot2docker’s Default Disk Space

During the authoring of this article, I ran into an interesting problem with boot2docker, in that my VM ran out of room to store images. This resulted in mysterious hanging of pulling images.

If you are moving a lot of images around, you may want to increase the amount of VM storage allocated by boot2docker:

$ boot2docker init -s 40000
The units shown are in gigabytes.