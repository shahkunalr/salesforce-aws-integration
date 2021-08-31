#/bin/sh
zip -r salesforceContactCreate.zip createContact.js node_modules
mv salesforceContactCreate.zip ./iac
cd ./iac
terraform apply --auto-approve
