<%*
const torah = eval(await tp.app.vault.adapter.read("Templates/Scripts/torah.js"))(tp);
const sefarim = ["Bereishis", "Shemos", "Vayikra", "Bamidbar", "Devarim"];
let sefer = String(tp.frontmatter.sefer ?? "").replace(/[\[\]]/g, "");
if (!sefer) sefer = (await tp.system.suggester(sefarim, sefarim, false, "Sefer")) ?? "";
const r = await torah.rashiBlock(sefer);
tR += `${r.heading}\n**Words:** ${r.words}`;
-%>
<% tp.file.cursor() %>

**What's bothering Rashi?**


**What's Rashi's answer?**


**What questions do we have on his answer?**


**What do we learn from this?**

