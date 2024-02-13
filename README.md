# Vulpar
A discord bot that replace in-game admin command.

# How to setup
- Remember, this also need a hosting service or self-host.
- You will also need to **enable HttpService** in your Roblox game to use this.
- You need to setup both **server** and **game** to make this working.

# Setup server
- You can use: AWS, glitch, ...
- You will need to setup nodejs (>= v18) and npm
- Follow these steps below to setup:


## Server installation
Download the code from this repo, clicking on the "Code" button and press **Download Zip**\
Or you can download from here: https://github.com/codernocook/Vulpar/archive/refs/heads/main.zip\

If you use **Terminal** with git installed:
```bash
git clone https://github.com/codernocook/Vulpar
```

After download finished, unzip the file, if you download instead of using `git`

## Configurate Environment variables
- If you can't see `.env` file, press CTRL + H on Windows
- Edit the `.env` like the instruction below.

```conf
token=          Discord bot token
port=           PORT number or just type 3000
prefix=         The Discord bot prefix, or just use default ":"
accessToken=    The Password for the Roblox game to access to the server
```

For example, this is the configurated file:

> [!WARNING]
> You will have to put discord bot token in the token, and you have to setup your own accessToken to prevent your server from getting hacked

```conf
token=Discord bot token
port=3000
prefix=:
accessToken=Thepassword
```

## Start
Type in **Terminal**:

Install command:
```bash
npm i
```

Start server command:
```bash
npm start
```

# Game Installation
1. Download the file from **[here](https://raw.githubusercontent.com/codernocook/Vulpar/main/roblox/Vulpar%20build%201.0.0.rbxm)**: https://raw.githubusercontent.com/codernocook/Vulpar/main/roblox/Vulpar%20build%201.0.0.rbxm
2. Drag and Drop the downloaded file into your Roblox game
3. Drag it and drop into "ServerScriptService".

## Replace
4. Replace the `README.apiURL.replace` with the URL of the website where the server is hosted.
5. Replace the `README.accessToken.replace` with the accessToken found in the server's `.env` file.

## Important
4. Allow HTTP by going to your Game Settings.

# Done
- if you can't setup just open an issue i guess, brrr