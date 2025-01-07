#!/bin/bash

json_file="$1"

# Dependency checks

if ! command -v jq &> /dev/null
    then
        echo "Missing dependency: 'jq' not installed."
        exit 1
fi

if ! command -v op &> /dev/null
    then
        echo "Missing dependency: 'op' not installed."
        exit 1
fi

if [ "$#" -ne 1 ]
    then
        echo "Usage: $0 <1Password Vault Item JSON file>"
        exit 1
fi

if [ ! -f "${json_file}" ]
    then
        echo "Error: File '${json_file}' not found."
        exit 1
fi

# Prompt user for Vault UUID (this info isn't in the exported JSON file)

read -p 'Enter Vault UUID: ' vault_uuid

# Get Vault Item UUID from JSON

vault_item_uuid=$(jq -r '.uuid' "${json_file}")

# Get primary file attachment reference for vault item

main_document_filename=$(jq -r '.details.documentAttributes.fileName' "${json_file}")
main_document_documentid=$(jq -r '.details.documentAttributes.documentId' "${json_file}")

# Get the rest of the file attachments for the vault item

attachments=$(jq -c '.details.sections[].fields[] | select(.k == "file") | .v' "${json_file}")

if [ -z "${attachments}" ]
    then
        echo "No attachments found in JSON file."
        exit 0
fi

# Download main document attachment before looping through the other attached files

echo "Downloading file attachments..."

echo "Downloading '${main_document_filename}'..."

op read op://${vault_uuid}/${vault_item_uuid}/${main_document_documentid} -o "${main_document_filename}" > /dev/null

    if [ $? -eq 0 ]
        then
            echo -e "\tSuccessfully downloaded: ${main_document_filename}"
        else
            echo -e "\tFailed to download: ${main_document_filename}"
    fi

# Loop through each file attachment reference then download it

echo "${attachments}" | while IFS= read -r attachment; do
    file_name=$(echo "${attachment}" | jq -r '.fileName')
    document_id=$(echo "${attachment}" | jq -r '.documentId')

    echo "Downloading '${file_name}'..."

    op read op://${vault_uuid}/${vault_item_uuid}/${document_id} -o "${file_name}" > /dev/null


    if [ $? -eq 0 ]
        then
            echo -e "\tSuccessfully downloaded: ${file_name}"
        else
            echo -e "\tFailed to download: ${file_name}"
    fi
done

echo "Attachments downloaded!"
