<%*
const torah = eval(await tp.app.vault.adapter.read("Templates/Scripts/torah.js"))(tp);
const parshiyos = {
  Bereishis: ["Bereishis", "Noach", "Lech Lecha", "Vayeira", "Chayei Sarah", "Toldos", "Vayeitzei", "Vayishlach", "Vayeishev", "Mikeitz", "Vayigash", "Vayechi"],
  Shemos: ["Shemos", "Va'eira", "Bo", "Beshalach", "Yisro", "Mishpatim", "Terumah", "Tetzaveh", "Ki Sisa", "Vayakhel", "Pekudei"],
  Vayikra: ["Vayikra", "Tzav", "Shemini", "Tazria", "Metzora", "Acharei Mos", "Kedoshim", "Emor", "Behar", "Bechukosai"],
  Bamidbar: ["Bamidbar", "Nasso", "Beha'aloscha", "Shelach", "Korach", "Chukas", "Balak", "Pinchas", "Matos", "Masei"],
  Devarim: ["Devarim", "Va'eschanan", "Eikev", "Re'eh", "Shoftim", "Ki Seitzei", "Ki Savo", "Nitzavim", "Vayeilech", "Ha'azinu", "V'zos Habracha"],
};
const list = Object.entries(parshiyos).flatMap(([s, ps]) => ps.map(p => [p, s]));
const [parasha, sefer] = await tp.system.suggester(list.map(x => x[0]), list, false, "Parasha") ?? ["", ""];
const date = tp.date.now("YYYY-MM-DD");
if (parasha && tp.file.title.startsWith("Untitled")) {
  try { await tp.file.rename(`${parasha} ${date}`); } catch (e) {}
}
const r = await torah.rashiBlock(sefer);
tR += `---\ndate: ${date}\nsefer: "[[${sefer}]]"\nparasha: "[[Parashas ${parasha}|${parasha}]]"\nlecturer:\n---\n${r.heading}\n**Words:** ${r.words}`;
-%>
<% tp.file.cursor() %>

**What's bothering Rashi?**


**What's Rashi's answer?**


**What questions do we have on his answer?**


**What do we learn from this?**

## Additional Notes

