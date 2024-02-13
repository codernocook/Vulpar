/*
    MIT License

    Copyright (c) 2024 codernocook

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

module.exports = (database) => {
    const { Client, REST, GatewayIntentBits, EmbedBuilder, PermissionsBitField, Permissions, Guild, GuildMember, Routes, ActivityType, Collection } = require('discord.js');
    const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent, GatewayIntentBits.GuildMessageReactions, GatewayIntentBits.GuildMembers] });
    require('dotenv').config(); // load the env
    const token = process.env["token"];
    let main_prefix = ":";

    // From environment variable
    if (process && process["env"] && process["env"]["prefix"] !== undefined && process["env"]["prefix"] !== null) {
        main_prefix = process["env"]["prefix"]?.toString();
    } else {
        main_prefix = ":";
    }

    const messageToken_generate = (length) => {
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
          result += characters.charAt(Math.floor(Math.random() * charactersLength));
          counter += 1;
        }
        return result;
    }
    
    const randomInteger = (min, max) => {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    
    client.on("ready", () => {
        console.log("[VulparBOT]: Bot started");
    })
    
    client.on("messageCreate", (message) => {
        // Action token
        const actionToken = messageToken_generate(randomInteger(50, 80));

        // Parser
        const args = message.content.slice(main_prefix.length).split(/ +/);
		const command = args.shift().toLowerCase();
		const messaggearray = message.content.split(" ");
		const argument = messaggearray.slice(1);
		const cmd = messaggearray[0];
    
        // If it's has => remove (this chance is rare btw)
        if (database.has(actionToken)) {
            database.remove(actionToken);
        }

        // Help command
        if (command === "help" || command === "hackingtut" || command === "heckingtut" || command === "tutorial" || command === "cmd" || command === "cmds") {
            return message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Help command :)\nCommands:\nhelp (hackingtut, heckingtut, tutorial, cmd, cmds) ** : View the help panel**\n\nSendcommand (sm) [player (username only, doesn't need to be in the game) : string] [messageContent : string] **: Send message as user (doesn't need to be in the game)**\n\nCodeexecution (codeexec, execution, exec, loadstring) [code : string] **: Execute code in Roblox server**\n\nKick [player (username, displayName and userid are accepted) : string] [reason (not required) : string] **: Kick a player**\n\nBan [player (username, displayName and userid are accepted) : string] [reason (not required) : string] **: Ban a player**\n\nUnban [player (username, displayName and userid are accepted) : string] [reason (not required) : string] **: Unban a player**\n\nKill [player (username, displayName and userid are accepted) : string] **: Kill a player**\n\nGod [player (username, displayName and userid are accepted) : string] **: Turn a player into god, so they won't take any damage**\n\nCrash [player (username, displayName and userid are accepted) : string] ** : Crash a player's client**\n\nSetwalkspeed (setws) [player (username, displayName and userid are accepted) : string] [walkspeed : number] **: Set a player's walkspeed**\n\nSetjumppower (setjp) [player (username, displayName and userid are accepted) : string] [jumppower: number] **: Set a player Jumppower (JumpHeight supported)**\n\nRespawn (res, re) [player (username, displayName and userid are accepted) : string] **: Respawn a player**\n\nCrashServer (crashss) **: Crashing a server and making them lagging**\n\nShutdown (off) [message : string] **: Shutdown all server**\n\nFreeze (fr) [player (username, displayName and userid are accepted) : string] **: Freeze a player's movement**\n\nUnFreeze (unfr) [player (username, displayName and userid are accepted) : string] **: Unfreeze player's movement**\n\nPrefix: ":"\nVersion: 1.0.0\nMade by **[Itzporium](<https://itzporium.is-a.dev/>)**`).setColor(`Blue`)] });
        }
    
        // Modules
        if ((command === "sendmessage" || command === "sm")) {
            // Send Message
            // Command: :sendmessage [player (username only, doesn't need to be joining the game) : string] [messageContent : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "sendMessage",
                    "content": {
                        "username": argument[0],
                        "message": argument.slice(1).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully sending message to Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a message content before sending.`).setColor(`Red`)] });
            }
        } else if (command === "codeexecution" || command === "codeexec" || command === "execution" || command === "exec" || command === "loadstring") {
            // Execute code by loadstring
            // Command: :codeexecution [code : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "execution",
                    "content": argument.slice(0).join(" ")
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully executing code on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a content before sending.`).setColor(`Red`)] });
            }
        } else if (command === "kick") {
            // Normal player kick in game
            // Command: :kick [player (username, displayName and userid are accepted) : string] [reason (not required) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "kick",
                    "content": {
                        "user": argument[0],
                        "reason": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully kicking player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "ban") {
            // Normal player ban in game
            // Command: :ban [player (username, displayName and userid are accepted) : string] [reason (not required) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "ban",
                    "content": {
                        "user": argument[0],
                        "reason": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully banned player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "unban") {
            // Normal player ban in game
            // Command: :unban [player (username, displayName and userid are accepted) : string] [reason (not required) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "unban",
                    "content": {
                        "user": argument[0],
                        "reason": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully unbanned player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "kill") {
            // Kill player
            // Command: :kill [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "kill",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully killing player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "god") {
            // Kill player
            // Command: :god [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "god",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully set god to player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "crash") {
            // Crash player client
            // Command: :crash [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "crash",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully crashed player.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "setwalkspeed" || command === "setws") {
            // Normal player ban in game
            // Command: :setwalkspeed [player (username, displayName and userid are accepted) : string] [walkspeed : number]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "setws",
                    "content": {
                        "player": argument[0],
                        "walkspeed": argument.slice(1).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully set walkspeed to player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "setjumppower" || command === "setjp") {
            // Set jump power, if the game use jump height => Calcuating from jump power to jump height
            // Command: :setjumppower [player (username, displayName and userid are accepted) : string] [jumppower: number]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "setjp",
                    "content": {
                        "player": argument[0],
                        "jumppower": argument.slice(1).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully set jumppower to player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "respawn" || command === "res" || command === "re") {
            // Respawn player character
            // Command: :respawn [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "res",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully respawning player on Roblox server.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "crashserver" || command === "crashss") {
            // Crashing server
            // Command: :crashserver
            database.set(actionToken, {
                "actionType": "crashss",
                "content": null
            })

            message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully crashsed server.`).setColor(`Green`)] });
        } else if (command === "shutdown" || command === "off") {
            // Shutdown server
            // Command: :shutdown [message : string]
            database.set(actionToken, {
                "actionType": "shutdown",
                "content": {
                    "message": argument.slice(0).join(" ") || "Server is shutting down."
                }
            })

            message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully shutdown server.`).setColor(`Green`)] });
        } else if (command === "freeze" || command === "fr") {
            // Freeze player
            // Command: :freeze [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "freeze",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully Freeze player.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        } else if (command === "unfreeze" || command === "unfr") {
            // Freeze player
            // Command: :freeze [player (username, displayName and userid are accepted) : string]
            if (argument.join("")?.toString().replace(" ", "") !== "") {
                database.set(actionToken, {
                    "actionType": "unfreeze",
                    "content": {
                        "player": argument.slice(0).join(" ")
                    }
                })

                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Successfully Unfreeze player.`).setColor(`Green`)] });
            } else {
                message.channel.send({ embeds: [new EmbedBuilder().setDescription(`Please include a player username or userid before sending request.`).setColor(`Red`)] });
            }
        }
    })
    
    // Login
    client.login(token);
}