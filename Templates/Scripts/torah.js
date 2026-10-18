// Shared helpers for the Chumash templates. Templates load it with:
// const torah = eval(await tp.app.vault.adapter.read("Templates/Scripts/torah.js"))(tp);
(tp) => {
  const app = tp.app;
  const english = { Bereishis: "Genesis", Shemos: "Exodus", Vayikra: "Leviticus", Bamidbar: "Numbers", Devarim: "Deuteronomy" };
  const names = { Bereishis: "בראשית", Shemos: "שמות", Vayikra: "ויקרא", Bamidbar: "במדבר", Devarim: "דברים" };
  const translation = "Metsudah Chumash, Metsudah Publications, 2009";
  const rashi = "Rashi Chumash, Metsudah Publications, 2009";

  const heb = n => {
    n = Number(n);
    let s = ["", "ק", "ר", "ש", "ת"][Math.floor(n / 100)];
    n %= 100;
    if (n === 15) return s + "טו";
    if (n === 16) return s + "טז";
    return s + ["", "י", "כ", "ל", "מ", "נ", "ס", "ע", "פ", "צ"][Math.floor(n / 10)] + ["", "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט"][n % 10];
  };
  const md = h => h.replace(/<b>(.*?)<\/b>/g, "**$1**").replace(/<i>(.*?)<\/i>/g, "*$1*").replace(/<[^>]+>/g, "").replace(/\*\*\s*(.*?)\s*\*\*/g, "**$1**").trim();
  const sefaria = async (ref, versions, textOnly) => {
    const q = versions.map(v => "version=" + encodeURIComponent(v)).join("&");
    const res = await tp.obsidian.requestUrl({ url: `https://www.sefaria.org/api/v3/texts/${ref}?${q}${textOnly ? "&return_format=text_only" : ""}`, throw: false });
    const get = lang => res.json?.versions?.find(v => v.language === lang)?.text ?? [];
    return { he: [get("he")].flat(), en: [get("en")].flat() };
  };

  // Full contents of a pasuk note: text, Rashi, and the lecture notes on it.
  const pasukContent = async (sefer, perek, pasuk) => {
    let text = "";
    try {
      const p = await sefaria(`${english[sefer]}.${perek}.${pasuk}`, ["hebrew", "english|" + translation], true);
      text = `${p.he[0].replace(/[֑-ֽ֯׀]/g, "")}\n\n${p.en[0]}\n\n`;
      const r = await sefaria(`Rashi_on_${english[sefer]}.${perek}.${pasuk}`, ["hebrew|" + rashi, "english|" + rashi]);
      if (r.he.length) text += "## Rashi\n" + r.he.map((he, i) => `${md(he)} ^rashi-${i + 1}\n\n${md(r.en[i] ?? "")}\n\n`).join("");
    } catch (e) {
      text = "_Couldn't load text from Sefaria._\n\n";
    }
    return `---\nsefer: "[[${sefer}]]"\nperek: ${perek}\npasuk: ${pasuk}\naliases:\n  - "${names[sefer]} ${heb(perek)}:${heb(pasuk)}"\n---\n${text}## From Lectures\n\`\`\`dataviewjs\nawait dv.view("Templates/Scripts/lecture-sections")\n\`\`\`\n\n## Notes\n`;
  };

  // Creates the pasuk note in Torah/<Sefer>/ if it doesn't exist yet.
  const ensurePasuk = async (sefer, perek, pasuk) => {
    const name = `${sefer} ${perek}.${pasuk}`;
    if (app.metadataCache.getFirstLinkpathDest(name, "")) return;
    const folder = `Torah/${sefer}`;
    if (!app.vault.getAbstractFileByPath(folder)) await app.vault.createFolder(folder);
    await app.vault.create(`${folder}/${name}.md`, await pasukContent(sefer, perek, pasuk));
  };

  // Asks for a pasuk and which Rashi, makes sure the pasuk note exists,
  // and returns the block's heading and words.
  const rashiBlock = async sefer => {
    const m = ((await tp.system.prompt("Pasuk (e.g. 1:3)")) ?? "").match(/(\d+)\D+(\d+)/);
    if (!m) return { heading: "## · [[Rashi]]", words: "" };
    const [, perek, pasuk] = m;
    const note = `${sefer} ${perek}.${pasuk}`;
    ensurePasuk(sefer, perek, pasuk).catch(() => {});
    let words = "", id = "";
    try {
      const r = await sefaria(`Rashi_on_${english[sefer]}.${perek}.${pasuk}`, ["hebrew|" + rashi]);
      const dh = r.he.map(t => (t.match(/<b>(.*?)<\/b>/)?.[1] ?? "").replace(/<[^>]+>/g, "").replace(/[.\s]+$/, "").trim());
      if (dh.length) {
        const i = await tp.system.suggester([...dh, "Other..."], [...dh.keys(), -1], false, "Which Rashi?");
        if (i >= 0) { words = dh[i]; id = `#^rashi-${i + 1}`; }
      }
    } catch (e) {}
    const dhLink = words ? ` · [[${note}${id}|${words}]]` : "";
    return { heading: `## [[${note}|${perek}:${pasuk}]] · [[Rashi]]${dhLink}`, words };
  };

  return { pasukContent, ensurePasuk, rashiBlock };
}
