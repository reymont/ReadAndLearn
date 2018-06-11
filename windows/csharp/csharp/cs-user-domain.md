
* [How to get Windows Login credentials using C#.Net? ](https://social.msdn.microsoft.com/Forums/vstudio/en-US/36e1bcfa-a46a-47a8-8b21-78357efe866b/how-to-get-windows-login-credentials-using-cnet?forum=netfxbcl)

```cs
WindowsIdentity.GetCurrent()
Environment.UserName
```

* [c# - How do I get the current windows user's name in username@domain format? - Stack Overflow ](https://stackoverflow.com/questions/12166589/how-do-i-get-the-current-windows-users-name-in-usernamedomain-format)

```cs
string[] temp = Convert.ToString(WindowsIdentity.GetCurrent().Name).Split('\\');
string userName = temp[1] + "@" + temp[0];
```


* [c# - Get domain name - Stack Overflow ](https://stackoverflow.com/questions/4161246/get-domain-name)


I found this question by the title. If anyone else is looking for the answer on how to just get the domain name, use the following environment variable.

```cs
System.Environment.UserDomainName
```
I'm aware that the author to the question mentions this, but I missed it at the first glance and thought someone else might do the same.

What the description of the question then ask for is the fully qualified domain name (FQDN).


I'm going to add an answer to try to clear up a few things here as there seems to be some confusion. The main issue is that people are asking the wrong question, or at least not being specific enough.

What does a computer's "domain" actually mean?

When we talk about a computer's "domain", there are several things that we might be referring to. What follows is not an exhaustive list, but it covers the most common cases:

A user or computer security principal may belong to an Active Directory domain.
The network stack's primary DNS search suffix may be referred to as the computer's "domain".
A DNS name that resolves to the computer's IP address may be referred to as the computer's "domain".
Which one do I want?

This is highly dependent on what you are trying to do. The original poster of this question was looking for the computer's "Active Directory domain", which probably means they are looking for the domain to which either the computer's security principal or a user's security principal belongs. Generally you want these when you are trying to talk to Active Directory in some way. Note that the current user principal and the current computer principal are not necessarily in the same domain.

Pieter van Ginkel's answer is actually giving you the local network stack's primary DNS suffix (the same thing that's shown in the top section of the output of ipconfig /all). In the 99% case, this is probably the same as the domain to which both the computer's security principal and the currently authenticated user's principal belong - but not necessarily. Generally this is what you want when you are trying to talk to devices on the LAN, regardless of whether or not the devices are anything to do with Active Directory. For many applications, this will still be a "good enough" answer for talking to Active Directory.

The last option, a DNS name, is a lot fuzzier and more ambiguous than the other two. Anywhere between zero and infinity DNS records may resolve to a given IP address - and it's not necessarily even clear which IP address you are interested in. user2031519's answer refers to the value of HTTP_HOST, which is specifically useful when determining how the user resolved your HTTP server in order to send the request you are currently processing. This is almost certainly not what you want if you are trying to do anything with Active Directory.

How do I get them?

Domain of the current user security principal

This one's nice and simple, it's what Tim's answer is giving you.
```cs
System.Environment.UserDomainName
```
Domain of the current computer security principal

This is probably what the OP wanted, for this one we're going to have to ask Active Directory about it.

```cs
System.DirectoryServices.ActiveDirectory.Domain.GetComputerDomain()
```
This one will throw a ActiveDirectoryObjectNotFoundException if the local machine is not part of domain, or the domain controller cannot be contacted.

Network stack's primary DNS suffix

This is what Pieter van Ginkel's answer is giving you. It's probably not exactly what you want, but there's a good chance it's good enough for you - if it isn't, you probably already know why.

```cs
System.Net.NetworkInformation.IPGlobalProperties.GetIPGlobalProperties().DomainName
```
DNS name that resolves to the computer's IP address

This one's tricky and there's no single answer to it. If this is what you are after, comment below and I will happily discuss your use-case and help you to work out the best solution (and expand on this answer in the process).