### Comparison of kptr_restrict Values
<p>
  <ul>
    <li> kptr_restrict = 0 (Default): Addresses are hashed before printing via %pK. </li>
    <li> kptr_restrict = 1: Kernel pointers printed using %pK are replaced with 0s unless the user possesses the CAP_SYSLOG capability and appropriate privileges. </li>
    <li> kptr_restrict = 2: Kernel pointers printed via %pK are always shown as 0s, blocking access regardless of user privileges. </li>
  </ul>
</p>
