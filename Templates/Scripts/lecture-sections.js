// Shows every lecture section whose heading links to this note (a pasuk, Rashi, etc).
const me = dv.current().file.path;
const links = line => [...line.matchAll(/\[\[([^\]|#]+)/g)].map(m => m[1]);
const blank = line => !line.trim() || /^\*\*What.*\?\*\*$/.test(line.trim()) || /^\*\*Words:\*\*/.test(line.trim());

const pages = dv.pages()
  .where(p => !p.file.folder.startsWith("Torah") && p.file.outlinks.some(l => l.path === me))
  .sort(p => p.date ?? p.file.ctime, "asc");

let found = 0;
for (const page of pages) {
  const lines = (await dv.io.load(page.file.path)).split("\n");
  for (let i = 0; i < lines.length; i++) {
    const h = lines[i].match(/^(#+)\s/);
    if (!h) continue;
    const isMe = t => app.metadataCache.getFirstLinkpathDest(t, page.file.path)?.path === me;
    const hits = links(lines[i]).some(isMe);
    if (!hits) continue;
    let end = i + 1;
    while (end < lines.length && !(lines[end].match(/^(#+)\s/)?.[1].length <= h[1].length)) end++;
    const body = lines.slice(i + 1, end);
    if (body.every(blank)) continue;
    const rest = lines[i].replace(/^#+\s*/, "").replace(/\[\[([^\]|#]+)[^\]]*\]\]/g, (m, t) => isMe(t) && !m.includes("#") ? "" : m).replace(/^[\s·]+|[\s·]+$/g, "");
    const label = [`[[${page.file.path}|${page.file.name}]]`, page.lecturer, rest].filter(Boolean).join(" · ");
    dv.paragraph(`### ${label}\n${body.join("\n")}`);
    found++;
  }
}
if (!found) dv.paragraph("*No lecture notes yet.*");
