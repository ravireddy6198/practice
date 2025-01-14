- name: variables
  hosts: local
  connection: local
  vars:
    course: "Devops with AWS"
    duration: 120hrs
    trainer: "Ravi Prakash"
  tasks:
  - name: print the variable
    ansible.builtin.debug:
     msg: "course is {{course}}, Duration is {{duration}}, trainer is {{trainer}}"