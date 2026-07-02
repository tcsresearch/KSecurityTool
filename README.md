# KSecurityTool - Kernel Security Tool

### More Restrictions for ptrace, BPF, and Linux Kernel Symbol Access
#### Fedora 44 plans to flip a few kernel parameters to strengthen security. Here’s the gist:

<hr>

####	kernel.yama.ptrace_scope

 This parameter restricts debugging tools like ptrace from attaching to processes unless explicitly allowed. The new default likely sets this to 1 (some discussions even lean towards 2 for stricter enforcement).

 Why? ptrace is a doorway that attackers have leveraged to spy on or manipulate processes. Tightening this forcefully shuts that door unless you consciously open it.

<hr>

####	kernel.kptr_restrict

 This parameter limits access to kernel symbol memory addresses in /proc/kallsyms. These symbols often help attackers craft kernel exploits using leaked information. By default, Fedora will likely set this to 1 (possibly 2 for those who love stronger fortifications).

<hr>

####	net.core.bpf_jit_harden

 This adds security to the JIT (just-in-time) compilation used by the Berkeley Packet Filter (BPF). A default of 1 enables hardening for unprivileged users, though Fedora might go for 2, which applies the same protections to privileged users—locking things down tightly.

<hr>

##### These individual changes target real-world threats, all while aligning Fedora with security best practices already embraced by other distributions like Arch and Ubuntu.

