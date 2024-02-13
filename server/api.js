module.exports = (database) => {
    const express = require("express");

    // Application
    const app = express();

    // Middleware
    app.use(express.json());

    // Nodejs handler
    process.on("uncaughtException", () => {});

    // Error handler
    app.use((err, req, res, next) => {
        if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
            return res.status(400).json({
                "status": false,
                "data": undefined
            })
        }
    })

    // Authentication
    app.use((req, res, next) => {
        try {
            if (res && req["body"] && req["body"]["accessToken"]) {
                if ((req["body"]["accessToken"] === process.env["accessToken"]) && (process.env["accessToken"] === req["body"]["accessToken"])) {
                    // Allow to go
                    return next();
                } else {
                    res.status(400).json({
                        "success": false,
                        "data": undefined
                    })
                }
            } else {
                res.status(400).json({
                    "success": false,
                    "data": undefined
                })
            }
        } catch {};
    })

    app.post("/getAction", (req, res) => {
        res.status(200).json({
            "success": true,
            "data": Object.fromEntries(database)
        })
    })

    app.post("/actionCompleted", (req, res) => {
        if (req && req["body"] && req["body"]["actionToken"] && typeof(req["body"]["actionToken"]) === "string") {
            if (database.has(req["body"]["actionToken"])) {
                database.delete(req["body"]["actionToken"]);

                res.status(200).json({
                    "success": true,
                    "data": Object.fromEntries(database)
                })
            }
        } else {
            res.status(400).json({
                "success": false,
                "data": undefined
            })
        }
    })

    // Start
    app.listen(process.env["port"] || 3000, () => { console.log("[VulparAPI]: API service started") })
}