import sql from "mssql"

const databaseConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,

  options: {
    encrypt: process.env.DB_ENCRYPT === "true",
    trustServerCertificate:
      process.env.DB_TRUST_SERVER_CERTIFICATE === "true"
  },

  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
}

let poolPromise

export function getConnection() {
  if (!poolPromise) {
    const pool = new sql.ConnectionPool(databaseConfig)

    pool.on("error", (error) => {
      console.error("Erro no pool do SQL Server:", error)
    })

    poolPromise = pool.connect().catch((error) => {
      poolPromise = undefined
      throw error
    })
  }

  return poolPromise
}

export { sql }