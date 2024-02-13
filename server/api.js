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