
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

* See the
  [application portfolio](https://github.com/sakaal/service_platform_ansible/wiki/Application-portfolio)
  for an exhaustive list of the applied specifications and implementations.

Infrastructure service       | Supported alternatives
---------------------------- | ----------------------
Administrative mail transfer | Any SMTP provider

Platform component                            | Supported alternatives
--------------------------------------------- | ---------------------------
Operating System (OS)                         | CentOS
Management access                             | SSH
Revision Control                              | Git
Configuration security and audit trail        | GnuPG
Command-line interpreter                      | Bash
Command-line plain-text search                | Grep
Text stream editing                           | Sed
Data compression                              | Gzip
Configuration Management                      | Ansible
Data transfer                                 | cURL
Data transfer                                 | LFTP
Job scheduling                                | Systemd Calendar Timers, Cron
File system event monitoring                  | Incron (inotify cron)
Network security                              | FirewallD
Backup data encryption                        | OpenSSL
Backup data storage, online, on-site          | Hetzner server backup space
Backup data storage, offline, off-site        | Private (service administrators)
Digital certificates                          | ITU-T Recommendation X.509
Certificate Authority (CA)                    | Any
Mail submission and transfer (MSA, MTA)       | Postfix
Electronic mail filtering                     | Amavis
Email virus scanning                          | ClamAV
Sender Policy Framework (SPF)                 | DynECT API to manage SPF TXT records
Domain Keys Identified Mail (DKIM)            | OpenDKIM
Virus definition updates                      | Freshclam
Unsolicited mail filtering                    | Apache SpamAssassin (currently inactive)
Email client for administrative and test use  | Alpine
Web server                                    | Apache HTTP Server
Directory service                             | OpenLDAP
Application Virtual Machine                   | Oracle Java
Software artifact management                  | Sonatype Nexus OSS
Continuous Integration (CI)                   | Jenkins CI
Relational Database Management System (RDBMS) | PostgreSQL
Application server                            | WildFly
Release management                            | Apache Maven

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
    * Directory administration (basic)
    * Database administration (basic)
1. [Administrative Client System (ACS)](https://github.com/sakaal/admin_client_ansible)
   ready for use
1. Previously deployed, operational [service infrastructure](https://github.com/sakaal/service_infra_ansible)
1. Service Platform configuration repository (this CMDB)
1. An X.509 private key and a wildcard certificate
   for the secure management domain

### Preparing the onsite backup space ###

See the [data backup plan](https://github.com/sakaal/service_platform_ansible/wiki/Data-backup-plan)
in the wiki.

Set up the backup access credentials in file
`~/workspace/com.example_main_ansible/group_vars/all/hetzner.yml`:

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

Keep the digital certificates under `{{ inventory_dir }}/roles/transport_layer_security/files`
with the following naming policy for wildcard certificates and their keys:

     files/certs/_.example.com-crt.pem
     files/private/_.example.com-key.pem

The public service domain certificate has the following naming policy:

     files/certs/public.test-crt.pem
     files/private/public.test-key.pem

Do remember to encrypt the private keys using Ansible Vault.

You may need to validate that you control a domain before you can request a
Certificate Authority (CA) to issue a certificate for it. If you are deploying
a new domain with a mail server, you may have to use a self-signed certificate
to get the mail server deployed first. Then you can use the mail server to
receive the domain validation emails sent by your CA.

## Deployment procedure

The playbooks are run on an
[Administrative Client System (ACS)](https://github.com/sakaal/admin_client_ansible)
that has access to the service infrastructure nodes and external services
via a secure private channel over the Internet.

Substitute your service management domain name for `example.com` (and
`com.example` in reverse order).

1. Check out the platform configuration repository (playbooks):

        git clone git@github.com:sakaal/service_platform_ansible.git
    * Your local copy of the platform configuration repository
      must be located next to the `service_commons_ansible` repository
      in the same parent directory.

1. Examine until you understand the configuration files.

1. Observe instructions found in the configuration files.

1. Open the sensitive data volume:

        sudo open_sensitive_data

1. Confirm that the service infrastructure deployment has previously generated
   appropriate SSH bastion host configuration in:

         ~/.ssh/config
    * When you run the playbooks on the ACS, the SSH client that Ansible uses
      will automatically read the user's SSH configuration from that file.

1. Deploy public network interfaces:

        ansible-playbook guest_networking.yml -i ../com.example_ansible_main/development
        ansible-playbook guest_networking.yml -i ../com.example_ansible_main/production

1. Deploy mail services:

        ansible-playbook mail_servers.yml -i ../com.example_ansible_main/production
   * Use the Sender Policy Framework (SPF)
     [testing tools](http://www.openspf.org/Tools)
     and Port25 Solutions
     [email verification service](http://www.port25.com/support/authentication-center/email-verification/)
     to test the results.

1. Deploy relational database management services:

        ansible-playbook database_servers.yml -i ../com.example_ansible_main/production

1. Deploy web services:

        ansible-playbook web_servers.yml -i ../com.example_ansible_main/production
   * To only update static web content on existing web servers:

        ansible-playbook websites.yml -i ../com.example_ansible_main/production

1. Deploy directory services:

        ansible-playbook directory_servers.yml -i ../com.example_ansible_main/production

1. Deploy software artifact management services:

        ansible-playbook artifact_servers.yml -i ../com.example_ansible_main/development

1. Deploy continuous integration services:

        ansible-playbook ci_servers.yml -i ../com.example_ansible_main/development

1. Deploy application servers:

        ansible-playbook wildfly8_servers.yml -i ../com.example_ansible_main/development
        ansible-playbook wildfly8_servers.yml -i ../com.example_ansible_main/production

1. Diaspora is a similar open source project that is currently
   used for reference and to start building a pilot user base.
   The new concept will later replace many of the features
   currently provided by Diaspora.
   Deploy Diaspora servers:

        ansible-playbook diaspora_servers.yml -i ../com.example_ansible_main/production
   * Do read the `roles/diaspora_pod` sources and follow the instructions.
     You need to at least copy the static web content under the main inventory
     websites directory.

1. Use the [Qualys SSL Labs](https://www.ssllabs.com/ssltest/) or similar
   analyzer to test that the SSL/TLS server configuration is in order.

## Application data restoration from archives

1. Insert a secure removable media device.

1. Begin restoration by collecting the keys:

        ansible-playbook restore_archives.yml -i ../com.example_ansible_main/development

1. Take the removable media to the secure offline host and process the keys.

        authorize_restore.sh

1. Bring the removable media back to the ACS.

1. Proceed with restoration:

        ansible-playbook restore_commit.yml -i ../com.example_ansible_main/development

Currently, some manual steps are still needed. See the source code for details.

## Continual improvement

Please feel free to submit your proposals for specific improvements
to this process module, its solution alternatives, or configuration items,
as pull requests or issues to this repository.

Let the [wiki](https://github.com/sakaal/service_platform_ansible/wiki)
serve as a part of the service knowledge management system (SKMS).

You may fork this module and adapt it for your needs (even for commercial use).
Please refer to the enclosed license documents for details.

Thank you for your interest and support to peer-to-peer service management.
