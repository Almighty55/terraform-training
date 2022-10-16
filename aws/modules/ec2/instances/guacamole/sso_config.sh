#cloud-config
runcmd:
  - >
    ln -s ../available-extensions/guacamole-auth-saml-1.2.0/guacamole-auth-saml-1.2.0.jar
    /home/ec2-user/guaws/guacamole/etc/extensions/guacamole-auth-0-saml-1.2.0.jar
write_files:
- content: |
      saml-idp-url: https://login.microsoftonline.com/020ae7ff-ffff-aaaa-0000-03bb2fe66189/saml2
      saml-entity-id: https://ec2-3-87-158-211.compute-1.amazonaws.com
      saml-callback-url: https://ec2-3-87-158-211.compute-1.amazonaws.com/
  owner: root:root
  permissions: '0644'
  path: /home/ec2-user/guaws/guacamole/etc/guacamole.properties