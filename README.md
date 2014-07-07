# Running Ansible

* Ping

```
ansible -i hosts all -m ping --ask-pass -u root
```

* Initial setup
```
ansible-playbook -i hosts initial-setup.yml --ask-pass
ansible-playbook -i hosts dotfiles.yml
```
