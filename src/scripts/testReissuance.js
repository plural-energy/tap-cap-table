import axios from "axios";
import { connectDB } from "../config/mongoose";
import StockIssuance from "../db/objects/transactions/issuance/StockIssuance.js";
import { stockReissue } from "./sampleData.js";

connectDB();

const main = async () => {
    const lastStockIssuance = await StockIssuance.find().sort({ updatedAt: -1 }).limit(1);
    console.log("lastStockIssuance", lastStockIssuance[0]);
    const { issuer, security_id, stakeholder_id, stock_class_id, quantity } = lastStockIssuance[0];

    console.log("⏳ | Creating stock reissuance");

    const stockReissueResp = await axios.post(
        "http://localhost:8080/transactions/reissue/stock",
        stockReissue(
            issuer, // Issuer ID
            stakeholder_id, // Stakeholder ID
            stock_class_id, // StockClass ID
            security_id, // Security ID
            ["2b14be59-2f4c-5bf7-ce44-b315f68c2088"], // Resulting Security IDs
            "Reissued"
        )
    );

    console.log("✅ | stockReissueResponse", stockReissueResp.data);
};

main()
    .then()
    .catch((err) => {
        console.error(err);
    });
