#!/bin/bash
cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible
tee -a playbook.yml > /dev/null << EOT
- hosts: localhost
  tasks:
    - name: Instalando Python3 e Virtualenv
      apt:
        pkg:
        - python3
        - virtualenv
        update_cache: yes
      become: yes
    - name: Git Clone
      ansible.builtin.git:
        repo: https://github.com/guilhermeonrails/clientes-leo-api.git
        dest: /home/ubuntu/tcc/
        version: master
        force: yes
    - name: Instalando dependencias com pip
      pip:
        virtualenv: /home/ubuntu/tcc/venv
        requirements: /home/ubuntu/tcc/requirements.txt
    - name: Alterando o hosts do settings
      lineinfile:
        path: /home/ubuntu/tcc/setup/settings.py
        regexp: 'ALLOWED_HOSTS'
        line: 'ALLOWED_HOSTS = ["*"]'
        backrefs: yes
    - name: Configurando o banco de dados
      shell: 'cd /home/ubuntu/tcc/;. venv/bin/activate; python manage.py migrate'
    - name: Carregando dados iniciais
      shell: 'cd /home/ubuntu/tcc/;. venv/bin/activate; python manage.py loaddata clientes.json'
    - name: Iniciando servidor
      shell: 'cd /home/ubuntu/tcc/;. venv/bin/activate; nohup python manage.py runserver 0.0.0.0:8000 & '
EOT
ansible-playbook playbook.yml