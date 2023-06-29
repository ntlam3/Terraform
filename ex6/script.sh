#cloud-config
package_upgrade: true
packages:
    - nginx
users:
    - default
    - name: test_user01
      passwd: "P@ssw0rd"
    