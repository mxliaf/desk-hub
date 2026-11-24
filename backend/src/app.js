// INICIAR BIBLIOTECA

import express from 'express'
import { getConnection, sql } from '../config/database.js'

const app = express()

app.use(express.json())

app.get("/", (_req, res) => {
    res.json({ok: true, servico: 'Desk-Hub API'})
})

function calculatePriority(impact, urgency) {
    const priorities = {
        "1-1": "P1",
        "1-2": "P2",
        "1-3": "P3",
        "2-1": "P2",
        "2-2": "P3",
        "2-3": "P4",
        "3-1": "P3",
        "3-2": "P4",
        "3-3": "P4"
    }

    return priorities[`${impact}-${urgency}`]
}

app.post("/api/incidents", async (req, res) => {
    const {
        title,
        description,
        category,
        impact,
        urgency,
        requesterId
    } = req.body

    if (
        !title ||
        !description ||
        !impact ||
        !urgency ||
        !requesterId
    ) {
        return res.status(400).json({
            error: "Preencha todos os campos obrigatórios"
        })
    }

    if (
        ![1, 2, 3].includes(impact) ||
        ![1, 2, 3].includes(urgency)
    ) {
        return res.status(400).json({
            error: "Impacto e urgência devem ser 1, 2 ou 3"
        })
    }

    const priority = calculatePriority(impact, urgency)

    try {
        const pool = await getConnection()

        const result = await pool
            .request()
            .input("title", sql.NVarChar(200), title)
            .input("description", sql.NVarChar(sql.MAX), description)
            .input("category", sql.NVarChar(100), category || null)
            .input("impact", sql.TinyInt, impact)
            .input("urgency", sql.TinyInt, urgency)
            .input("priority", sql.Char(2), priority)
            .input("requesterId", sql.Int, requesterId)
            .query(`
                INSERT INTO dbo.incidents (
                    title,
                    description,
                    category,
                    impact,
                    urgency,
                    priority,
                    requester_id
                )
                OUTPUT
                    INSERTED.id,
                    INSERTED.incident_number,
                    INSERTED.title,
                    INSERTED.description,
                    INSERTED.category,
                    INSERTED.impact,
                    INSERTED.urgency,
                    INSERTED.priority,
                    INSERTED.status,
                    INSERTED.requester_id,
                    INSERTED.created_at
                VALUES (
                    @title,
                    @description,
                    @category,
                    @impact,
                    @urgency,
                    @priority,
                    @requesterId
                )
            `)

        return res.status(201).json(result.recordset[0])
    } catch (error) {
        console.error(error)

        return res.status(500).json({
            error: "Não foi possível criar o incidente"
        })
    }
})

export default app //exportar app para o server
