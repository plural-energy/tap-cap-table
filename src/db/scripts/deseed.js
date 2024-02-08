import { deseedDatabase } from "../../tests/integration/utils";

const runDeseed = async () => {
    try {
        await deseedDatabase();
    } catch (err) {
        console.log("❌ Error deseeding database:", err);
    }
};

runDeseed();
