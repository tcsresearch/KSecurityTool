### Quick Context on Security Values (ptrace_scope)
<p>
  <ul>
<li> 0: Not Secure. Any process under the same user ID can hook into other running processes using ptrace. This allows easy credential theft or malware injection. </li>
<li> 1: Secure Baseline. A process can only trace its own direct child processes (e.g., a debugger launching a binary). </li>
<li> 2 or 3: Highly Secure. Requires root privileges (CAP_SYS_PTRACE) or completely locks down process tracing on the system. </li>
  </ul>
</p>
