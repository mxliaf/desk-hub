import "dotenv/config"
import app from "./app.js"
import { getConnection } from "../config/database.js"

const PORT = process.env.PORT || 3000

async function startServer() {
    try {
        await getConnection()

        console.log("Conectado ao SQL Server")

        app.listen(PORT, () => {
            console.log(`DeskHub API executando na porta ${PORT}`)
        })
    } catch (error) {
        console.error("Não foi possível iniciar a aplicação: ", error)
        process.exit(1)
    }
}

startServer()
