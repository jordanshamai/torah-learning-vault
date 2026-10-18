<%*
const torah = eval(await tp.app.vault.adapter.read("Templates/Scripts/torah.js"))(tp);
const [, sefer, perek, pasuk] = tp.file.title.match(/^(.+) (\d+)\.(\d+)$/);
try { await tp.file.move(`Torah/${sefer}/${tp.file.title}`); } catch (e) {}
tR += await torah.pasukContent(sefer, perek, pasuk);
-%>
