
# Service Platform

This is a configuration management database (CMDB)
for tracking configuration items (CIs) related to deployment of
web servers, message transfer agents (MTA), database management
systems (DBMS), application virtual machines, development tools,
and their access controls and cryptographic credentials
during service transition and operation.

The platform configuration is deployed on virtual machines
comprising an online managed service.

A web server responds to requests from user agents and delivers documents
over the Hypertext Transfer Protocol (HTTP) also functioning as a proxy
to backend application servers.

A message transfer agent provides electronic mail resources based on
the Simple Mail Transfer Protocol (SMTP), the Post Office Protocol (POP3),
and the Internet Message Access Protocol (IMAP).

A database management system facilitates data organization, persistence,
modification, deletion, indexing, retrieval, security, concurrency control,
data integrity and recovery.

An application virtual machine provides a platform-independent programming
and execution environment.

## Current implementation

This Git repository contains Ansible playbooks for
the provision of a managed service platform based on the
following external services, software applications and components:

Infrastructure service       | Supported alternatives
---------------------------- | ----------------------
Administrative mail transfer | Any SMTP provider ([RFC 5321](http://tools.ietf.org/html/rfc5321), [RFC 6409](http://tools.ietf.org/html/rfc6409))

Platform component                            | Supported alternatives
--------------------------------------------- | ---------------------------
Operating System                              | CentOS
Management access                             | SSH
Revision Control                              | Git
Configuration security and audit trail        | GnuPG, OpenPGP, [RFC 4880](http://tools.ietf.org/html/rfc4880)
Configuration Management                      | Ansible
Network security                              | FirewallD
Backup data encryption                        | OpenSSL
Backup data storage, online, on-site          | Hetzner server backup space
Backup data storage, offline, off-site        | Private (service administrators)
Digital certificates                          | ITU-T Recommendation X.509
Certificate Authority (CA)                    | Any
Web Server                                    | Apache HTTP Server
Application Virtual Machine                   | Oracle Java
Software Artifact Management                  | Sonatype Nexus OSS
Continuous Integration (CI)                   | Jenkins CI
Release Management                            | Apache Maven (coming)
Application Server                            | Wildfly (coming)
Mail Transfer Agent (MTA)                     | Postfix (coming)
Electronic Mail Filtering                     | Amavis (coming)
Email Virus Scanning                          | ClamAV (coming)
Relational Database Management System (RDBMS) | PostgreSQL (coming)

## Prerequisites

1. Competencies
    * System administration (intermediate)
    * Configuration management (intermediate)
    * Web of trust (GnuPG) (basic)
    * Public key infrastructure (PKI) (basic)
    * Web server maintenance (basic)
    * Java EE (intermediate)
    * Continuous integration (basic)
    * Release management (basic)
    * Mail server administration (basic)
    * Database administration (basic)
1. [Administrative Client System (ACS)](https://github.com/sakaal/admin_client)
   ready for use
1. Previously deployed, operational [service infrastructure](https://github.com/sakaal/service_infra_ansible)
1. Service Platform configuration repository (this CMDB)
1. An X.509 private key and a wildcard certificate
   for the secure management domain

### Preparing the onsite backup space ###

See the [data backup plan](https://github.com/sakaal/service_platform_ansible/wiki/Data-backup-plan) in the wiki.

Set up the backup access credentials in file
`/mnt/sensitive_data/etc/ansible/vars/hetzner.yml`:

    #
    # Use the Hetzner Robot web console to order the backup space
    # that is included in the price of the server.
    #
    # roles/hetzner_backup_authorized_keys
    #
    backup_onsite_protocol: sftp
    backup_onsite_account: u12345
    backup_onsite_service: "{{ backup_onsite_account }}.your-backup.de"
    backup_onsite_password: 574CorsGTDUMMYG8

### Preparing the digital certificates ###

Keep the digital certificates under `/mnt/sensitive_data/etc/pki/tls/`
with the following naming policy for wildcard certificates and their keys:

     /mnt/sensitive_data/etc/pki/tls/certs/_.example.com-crt.pem
     /mnt/sensitive_data/etc/pki/tls/private/_.example.com-key.pem

## Deployment procedure

The playbooks are run on an
[Administrative Client System (ACS)](https://github.com/sakaal/admin_client)
that has access to the service infrastructure nodes and external services
via a secure private channel over the Internet.

Substitute your service management domain name for `example.com` (and
`com.example` in reverse order).

1. Check out the platform configuration repository (playbooks):

        git clone git@github.com:sakaal/service_platform_ansible.git
    * Your local copy of the platform configuration repository
      must be located next to the `service_infra_ansible` repository
      in the same parent directory.

1. Examine until you understand the configuration files.

1. Observe instructions found in the configuration files.

1. Open the sensitive data volume:

        sudo open_sensitive_data

1. Confirm that the service infrastructure deployment has previously generated
   appropriate SSH bastion host configuration in:

         /mnt/sensitive_data/etc/ssh/ssh_config
    * When you run the playbooks from the `service_platform_ansible`
      directory, Ansible will automatically pick up the SSH bastion
      host configuration based on the `ansible.cfg` file located in
      that directory.

1. Deploy public network interfaces:

        ansible-playbook guest_networking.yml -i ../com.example.ansible_main/production

1. Deploy web servers:

        ansible-playbook web_servers.yml -i ../com.example.ansible_main/production

1. Deploy software artifact management services:

        ansible-playbook artifact_servers.yml -i ../com.example.ansible_main/production

1. Deploy continuous integration services:

        ansible-playbook ci_servers.yml -i ../com.example.ansible_main/production

## Continual improvement

Please feel free to submit your proposals for specific improvements
to this process module, its solution alternatives, or configuration items,
as pull requests or issues to this repository.

Let the wiki serve as a part of the service knowledge management system (SKMS).

You may fork this module and adapt it for your needs (even for commercial use).
Please refer to the enclosed license documents for details.

Thank you for your interest and support to peer-to-peer service management.
