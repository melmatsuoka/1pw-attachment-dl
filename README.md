# 1Password file-attachment downloader

This Bash script use the [1Password CLI](https://developer.1password.com/docs/cli) tool to automatically download all of the file attachments within a selected 1Password Vault Item.

I wrote this for the purposes of extracting a lot of personal documents that were dragged-and-dropped into my family's shared 1Password vault from the macOS Finder. Unbeknownst to me, the current version of 1Password (as of this writing, v8.10.56) does not import multiple files into separate vault items, but instead creates a "Document" item with the name of the first file in the list of dragged files, and then adds the rest of the files to that same Document item as attached files. For example:

![1pw_dl_01](https://github.com/user-attachments/assets/2cd7db32-1759-4640-bcea-de73ebb3f3cd)
![1pw_dl_02](https://github.com/user-attachments/assets/88443612-da02-4199-9d50-0b56aee3b327)
![1pw_dl_03](https://github.com/user-attachments/assets/4c02f9cd-b46b-4d5f-970c-74e514403004)

This drives me absolutely crazy, so I wrote this script to undo some of the damage done by this flawed import behavior.

## Usage

The script assumes that you have already [installed and configured](https://developer.1password.com/docs/cli/get-started) the 1Password `op` CLI tool to work with your 1Password account. 

First, make sure that the "Show debugging tools" option is enabled in your 1Password "Advanced" settings.

![1pw_dl_07](https://github.com/user-attachments/assets/9728856b-6c06-4e3d-a7d8-d1b63693973f)

To use the script, you'll need to export the Vault item to a JSON file. Unfortunately you (currently) can't simply export a selected Vault item directly to a JSON file. But you _can_ at least copy the JSON to your clipboard, by right-clicking on the Vault item, then pasting the JSON into a text editor.

![1pw_dl_04](https://github.com/user-attachments/assets/15366609-2b4e-4f62-8382-22e3ff4f5997)

Copy the UUID of the Vault where the Vault _item_ is currently located (unfortunately the Vault UUID is not stored in the JSON of the Vault Item itself).

Run the script, specifying the JSON file as the argument, then paste in the Vault UUID when prompted. The script will download all of the file attachements for that item in the current working directory.

## Individually re-uploading files to 1Password

To upload each file back into 1Password as individual vault items, it's a simple matter of using the `op document create` command to upload each file to a new Document entry:

```
for file in *
  do
    op document create "$file" --vault VAULT_UUID --title "$(basename $file)"
  done
```







