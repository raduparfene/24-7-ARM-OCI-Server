# Must have prerequisite:
- Install OCI locally:
```shell
./oci/shell_scripts/01_install_oci_locally.sh
```

- Configure terraform.tfvars with your variables, e.g.:
```shell
compartment_ocid = "ocid1.tenancy.oc1.."
ssh_public_key_path = "path/to/your/key.pub"
vnc_password = "password_you_will_use_to_connect_to_the_gui"
github_cs_repo = "your desired repository, used as env var so the instance pulls the repository from git"
my_public_ip = "your public IPv4 IP, used for SSH connection"
```

- Create a key pair and use it for terraform to access the instance
```shell
test -f oci/login-key || (ssh-keygen -t ed25519 -f oci/login-key -N "" && chmod 600 oci/login-key)
mkdir -p ~/.ssh
cp oci/login-key ~/.ssh/oci-login-key
chmod 600 ~/.ssh/oci-login-key
```

- OCI API signing key pair (aws equivalent: access key id + secret)
```shell
oci setup config
# user ocid: Profile -> User Settings -> OCID                     ocid1.user.oc1..
# tenacy ocid: Tenacies -> user -> OCID                           ocid1.tenancy.oc1..
# region: Regions -> by number                                    choose a number
# Do you want to generate a new API Signing RSA key pair?         Yes
# No key passphrase                                               N/A
```

- Paste the content of the following shell line inside: Profile -> User settings -> My profile -> Tokens and keys -> Add API keys -> Paste a public key
```shell
cat ~/.oci/oci_api_key_public.pem
```

- Test it with the line below. You should get Private key phrase with a JSON.
```shell
oci os ns get
```




# Prepare Infrastructure
## 1. Modify ```bootstrap.sh``` script according to your needs

## 2. Inside project root directory, execute:
```shell
terraform -chdir=terraform/stacks/base init

(terraform -chdir=terraform/stacks/base state rm oci_core_public_ip.reserved || true) && terraform -chdir=terraform/stacks/base destroy -auto-approve
(terraform -chdir=terraform/stacks/base import oci_core_public_ip.reserved ocid1.publicip.oc1.eu-frankfurt-1.amaaaaaaayo4g5iahdp3kmdpyygarrldrgrlw67us5hluwb6dp432qa36t5a || true) && terraform -chdir=terraform/stacks/base plan
(terraform -chdir=terraform/stacks/base import oci_core_public_ip.reserved ocid1.publicip.oc1.eu-frankfurt-1.amaaaaaaayo4g5iahdp3kmdpyygarrldrgrlw67us5hluwb6dp432qa36t5a || true) && terraform -chdir=terraform/stacks/base apply -auto-approve
# the next times, it is sufficient to execute only destroy and apply
```


# Connect to the SSH and verify the machine logs:
```shell
ssh -i ~/.ssh/oci-login-key ubuntu@<YOUR_TERRAFORM_OUTPUT_IP>
sudo tail -f /var/log/cloud-init-output.log
```


# If you prefer using the GUI, you can do so by having a SSH connection open on port 5901. But wait for the installation to finish:
```shell
ssh -i ~/.ssh/oci-login-key ubuntu@<YOUR_TERRAFORM_OUTPUT_IP> -L 5901:localhost:5901
# Then open a RealVNC Viewer on localhost:5901, with the password set by you inside terraform.tfvars
```
# In case you get errors with your ssh key, you can regenerate it with:
```shell
ssh-keygen -f '~/.ssh/known_hosts' -R '<YOUR_TERRAFORM_OUTPUT_IP>'
```
