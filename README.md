## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![](https://github.com/kchen03/Monash-Cybersecurity/blob/main/Diagrams/Azure-network-elk-diagram.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the **playbook** file may be used to install only certain pieces of it, such as Filebeat.

#### Playbook 1: pentest.yml
```
---
- name: Config Web VM with Docker
  hosts: webservers
  become: true
  tasks:
    - name: docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present

    - name: Install pip3
      apt:
        name: python3-pip
        state: present

    - name: Install Docker python module
      pip:
        name: docker
        state: present

    - name: download and launch a docker web container
      docker_container:
        name: dvwa
        image: cyberxsecurity/dvwa
        state: started
        restart_policy: always
        published_ports: 80:80

    - name: Enable docker service
      systemd:
        name: docker
        enabled: yes
```


#### Playbook 2: install-elk.yml
```
---
- name: Configure Elk VM with Docker
  hosts: elk
  remote_user: azadmin
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present

      # Use apt module
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

      # Use pip module (It will default to pip3)
    - name: Install Docker module
      pip:
        name: docker
        state: present

      # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144

      # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes

      # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # Please list the ports that ELK runs on
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044

      # Use systemd module
    - name: Enable service docker on boot
      systemd:
        name: docker
        enabled: yes
```
#### Playbook 3: filebeat-playbook.yml
```
---
- name: installing and launching filebeat
  hosts: webservers
  become: yes
  tasks:

  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb

  - name: install filebeat deb
    command: dpkg -i filebeat-7.4.0-amd64.deb

  - name: drop in filebeat.yml
    copy:
      src: /etc/ansible/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml

  - name: enable and configure system module
    command: filebeat modules enable system

  - name: setup filebeat
    command: filebeat setup

  - name: start filebeat service
    command: service filebeat start

  - name: enable service filebeat on boot
    systemd:
      name: filebeat
      enabled: yes
```

#### Playbook 4: metricbeat-playbook.yml
```
---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:
    # Use command module
  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb

    # Use command module
  - name: install metricbeat
    command: dpkg -i metricbeat-7.4.0-amd64.deb

    # Use copy module
  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

    # Use command module
  - name: enable and configure docker module for metric beat
    command: metricbeat modules enable docker

    # Use command module
  - name: setup metric beat
    command: metricbeat setup

    # Use command module
  - name: start metric beat
    command: service metricbeat start

    # Use systemd module
  - name: enable service metricbeat on boot
    systemd:
      name: metricbeat
      enabled: yes
```

    
This document contains the following details:

- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly **available**, in addition to restricting **access** to the network.

- Load balancers distribute network traffic across multiple servers, to ensure no single server is overworked. This allows increase in responsiveness of applications and also prevents DDoS attacks. 
- The advantage of a jump box server is to provide a separate security zone for controlled access for administrative to connect to first. 

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the **data** and system **logs**.

- Filebeat watches for log file data and locations specified. It keeps a state of each file it finds stores it away.
- Metricbeat collects metrics from operating systems and stashes the metrics and statistics away.

The configuration details of each machine may be found below.
_Note: Use the [Markdown Table Generator](http://www.tablesgenerator.com/markdown_tables) to add/remove values from the table_.

| Name     | Function        | IP Address | Operating System |
| -------- | --------------- | ---------- | ---------------- |
| Jump Box | Gateway         | 10.0.0.1   | Linux            |
| Web-1    | DVWA            | 10.1.0.5   | Linux            |
| Web-2    | DVWA            | 10.1.0.9   | Linux            |
| Web-3    | DVWA            | 10.1.0.10  | Linux            |
| Elk      | ELK             | 10.1.0.10  | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the **host** machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:

- IP address of Home Machine (14.202.30.45)
- Web-1 (10.1.0.4)
- Web-2 (10.1.0.9)
- Web-3 (10.1.0.10)

Machines within the network can only be accessed by **the Jump box machine.**

- The Home Machine was granted access to the Elk machine, and its IP address is 14.202.30.45

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses | Allowed Ports |
|----------|---------------------|----------------------|---------------|
| Jump Box | Yes (SSH)           | 14.202.30.45         | 22            |
| Web-1    | Yes (HTTP)          | 14.202.30.45         | 80            |
| Web-2    | Yes (HTTP)          | 14.202.30.45         | 80            |
| Web-3    | Yes (HTTP)          | 14.202.30.45         | 80            |
| Elk-1    | Yes (HTTP)          | 14.202.30.45         | 5601          |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because Ansible has automated configurations.

- The main advantage of automating configuration with Ansible is security. This allows Ansible to not require any remote operators and as a result Ansible has a low attack surface area and is easy to deploy

The playbook implements the following tasks:

In the Install ELK.yml: the following steps are:
- Install Docker
- Instal Python3
- Install Docker Python Module
- Increase virtual memory to support ELK stack
- Adding the list of ports that ELK can run on: 5601, 9200 5044
- Download ELk and launch ELK

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![](https://github.com/kchen03/Monash-Cybersecurity/blob/main/Diagrams/Elk%20docker%20ps.PNG)

### Target Machines & Beats

This ELK server is configured to monitor the following machines:

- The 3 VMs we made
- Web-1: 10.1.0.5
- Web-2: 10.1.0.9
- Web-3: 10.1.0.10

We have installed the following Beats on these machines:

- FileBeat
- MetricBeat

These Beats allow us to collect the following information from each machine:

- FileBeat collects copies of files on the server and stashes them away to a specified location, acting as a monitoring agent to compile log events for indexing. 
- MetricBeat collects metrics and data from the services running on an operating system that is running on the server. The complied data is then stored to a specified location that can be used later on for statistics.

### Using the Playbook

In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:

- Copy the filebeat-config.yml file to /etc/ansible/files/filebeat-config.yml to ensure we have a preconfigured file somewhere.
- Update the filebeat-config.yml file to include the IP address of the ELK machine.
By adding in the following lines:
```
[webservers]
10.1.0.5 ansible_python_interpreter=/usr/bin/python3
10.1.0.9 ansible_python_interpreter=/usr/bin/python3
10.1.0.10 ansible_python_interpreter=/usr/bin/python3

[elkservers]
10.0.0.4 ansible_python_interpreter=/usr/bin/python3
```
- Updating the Ansible Configuration file /etc/ansible/ansible.cfg and setting the remote_user parameter to the admin user of the web servers

#### Run the playbook
1. Start an ssh session with the Jump Box `~$ ssh sysadmin@<Jump Box Public IP>`
2. Start the Ansible Docker container `~$ sudo docker start <Ansible Container>`
3. Attach a shell to the Ansible Docker container with the command `~$ sudo docker attach <Ansible Container Name>`
4. Run the playbooks with the following commands:
	* `ansible-playbook /etc/ansible/pentest.yml`
	* `ansible-playbook /etc/ansible/install-elk.yml`
	* `ansible-playbook /etc/ansible/roles/filebeat-playbook.yml`

- Finally once running the playbooks and no errors are in the output. We can navigate to Kibanan and check the installation has worked. By navigating to the Kibana dashboard and looking under system logs.
- Navigate to Filebeat installation page on the ELK server GUI (http://20.37.242.41:5601/app/kibana) to check that the installation worked as expected.
