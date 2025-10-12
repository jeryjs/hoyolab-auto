const express = require("express");

const createAPI = (port = 3000) => {
	const api = express();

	api.get("/api/genshin/notes", async (req, res) => {
		try {
			const accounts = app.HoyoLab.getActiveAccounts({ whitelist: "genshin" });
			
			if (accounts.length === 0) {
				return res.status(404).json({ error: "No accounts found" });
			}

			const results = [];
			for (const account of accounts) {
				const platform = app.HoyoLab.get("genshin");
				const notes = await platform.notes(account);
				
				if (notes.success) {
					results.push({
						uid: account.uid,
						nickname: account.nickname,
						region: account.region,
						...notes.data
					});
				}
			}

			res.json({ success: true, data: results });
		}
		catch (error) {
			res.status(500).json({ error: error.message });
		}
	});

	api.get("/api/genshin/expedition", async (req, res) => {
		try {
			const accounts = app.HoyoLab.getActiveAccounts({ whitelist: "genshin" });
			
			if (accounts.length === 0) {
				return res.status(404).json({ error: "No accounts found" });
			}

			const results = [];
			for (const account of accounts) {
				if (!account.expedition.check) {
					continue;
				}

				const platform = app.HoyoLab.get("genshin");
				const notes = await platform.notes(account);
				
				if (notes.success) {
					results.push({
						uid: account.uid,
						nickname: account.nickname,
						region: account.region,
						expedition: notes.data.expedition
					});
				}
			}

			res.json({ success: true, data: results });
		}
		catch (error) {
			res.status(500).json({ error: error.message });
		}
	});

	api.get("/api/genshin/stamina", async (req, res) => {
		try {
			const accounts = app.HoyoLab.getActiveAccounts({ whitelist: "genshin" });
			
			if (accounts.length === 0) {
				return res.status(404).json({ error: "No accounts found" });
			}

			const results = [];
			for (const account of accounts) {
				if (!account.stamina.check) {
					continue;
				}

				const platform = app.HoyoLab.get("genshin");
				const notes = await platform.notes(account);
				
				if (notes.success) {
					results.push({
						uid: account.uid,
						nickname: account.nickname,
						region: account.region,
						stamina: notes.data.stamina
					});
				}
			}

			res.json({ success: true, data: results });
		}
		catch (error) {
			res.status(500).json({ error: error.message });
		}
	});

    api.use((req, res) => {
        res.status(404).json({ error: "Endpoint not found", available_routes: ["/api/genshin/notes", "/api/genshin/expedition", "/api/genshin/stamina"] });
    });

	const server = api.listen(port, () => {
		app.Logger.info("API", `Server running on http://localhost:${port}`);
	});

	return server;
};

module.exports = { createAPI };
