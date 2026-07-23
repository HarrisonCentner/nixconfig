{ inputs, ... }:
{
  _module.args.appleColorEmoji =
    pkgs:
    let
      # Upstream's vendored Unicode sequence inventory, pinned to a commit.
      emojiSequences = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/samuelngs/apple-emoji-ttf/484daf4e13942437e083d881cae39fbc92d837e1/sequences/emoji-test.txt";
        hash = "sha256-HYqUT4jXlS9+98UWf+88Z5lbyuJFQ5SXECMbA6IBrNo=";
      };

      # The Linux build ligates only via AAT morx, which Blink ignores, so
      # Electron apps render skin-tone/ZWJ sequences as separate glyphs.
      # Shape every Unicode sequence with HarfBuzz (which does apply morx) to
      # learn its composed glyph, emit those as an OpenType GSUB ccmp ligature
      # table, then drop the AAT tables so morx can't shadow GSUB.
      addGsub = pkgs.writeText "add-gsub.py" ''
        from __future__ import annotations
        import sys
        from fontTools.ttLib import TTFont
        from fontTools.ttLib.tables import otTables as ot
        from fontTools.ttLib.tables.G_S_U_B_ import table_G_S_U_B_
        from fontTools.otlLib.builder import buildLookup
        import uharfbuzz as hb

        src, seq_file, dst = sys.argv[1], sys.argv[2], sys.argv[3]

        sequences = []
        for line in open(seq_file, encoding="utf-8"):
            line = line.split("#", 1)[0].strip()
            if not line or ";" not in line:
                continue
            cps, status = (p.strip() for p in line.split(";", 1))
            if status not in ("fully-qualified", "minimally-qualified", "unqualified"):
                continue
            parts = cps.split()
            if len(parts) < 2:
                continue
            sequences.append(tuple(int(p, 16) for p in parts))

        face = hb.Face(hb.Blob.from_file_path(src))
        hbfont = hb.Font(face)

        def shape(seq):
            buf = hb.Buffer()
            buf.add_codepoints(list(seq))
            buf.guess_segment_properties()
            hb.shape(hbfont, buf, {})
            return [hbfont.glyph_to_string(i.codepoint) for i in buf.glyph_infos]

        font = TTFont(src)
        cmap = font.getBestCmap()
        glyph_order = set(font.getGlyphOrder())

        rules = []
        for seq in sequences:
            out = shape(seq)
            if len(out) != 1:
                continue
            replacement = out[0]
            if replacement not in glyph_order or replacement == ".notdef":
                continue
            comps = []
            for cp in seq:
                g = cmap.get(cp)
                if g is None or g not in glyph_order:
                    break
                comps.append(g)
            if len(comps) == len(seq):
                rules.append((tuple(comps), replacement))

        print("gsub rules:", len(rules))
        assert len(rules) > 2000, "too few ligature rules; font layout changed?"

        deduped = {}
        for comps, repl in rules:
            deduped.setdefault(comps, repl)
        by_first = {}
        for comps, repl in deduped.items():
            by_first.setdefault(comps[0], []).append((comps, repl))

        subtable = ot.LigatureSubst()
        subtable.ligatures = {}
        for first, group in by_first.items():
            group.sort(key=lambda item: -len(item[0]))  # longest match first
            ligs = []
            for comps, repl in group:
                lig = ot.Ligature()
                lig.LigGlyph = repl
                lig.CompCount = len(comps)
                lig.Component = list(comps[1:])
                ligs.append(lig)
            subtable.ligatures[first] = ligs

        def script_record(tag):
            rec = ot.ScriptRecord()
            rec.ScriptTag = tag
            rec.Script = ot.Script()
            rec.Script.DefaultLangSys = ot.DefaultLangSys()
            rec.Script.DefaultLangSys.ReqFeatureIndex = 0xFFFF
            rec.Script.DefaultLangSys.FeatureIndexCount = 1
            rec.Script.DefaultLangSys.FeatureIndex = [0]
            rec.Script.LangSysRecord = []
            rec.Script.LangSysCount = 0
            return rec

        gsub = ot.GSUB()
        gsub.Version = 0x00010000
        gsub.ScriptList = ot.ScriptList()
        gsub.ScriptList.ScriptRecord = [script_record("DFLT"), script_record("latn")]
        gsub.ScriptList.ScriptCount = 2
        feature = ot.FeatureRecord()
        feature.FeatureTag = "ccmp"
        feature.Feature = ot.Feature()
        feature.Feature.LookupListIndex = [0]
        feature.Feature.LookupCount = 1
        gsub.FeatureList = ot.FeatureList()
        gsub.FeatureList.FeatureRecord = [feature]
        gsub.FeatureList.FeatureCount = 1
        gsub.LookupList = ot.LookupList()
        gsub.LookupList.Lookup = [buildLookup([subtable], flags=0, markFilterSet=None)]
        gsub.LookupList.LookupCount = 1

        table = table_G_S_U_B_()
        table.table = gsub
        font["GSUB"] = table

        for tag in ("morx", "feat", "trak"):
            if tag in font:
                del font[tag]

        font.save(dst)
      '';
    in
    pkgs.stdenvNoCC.mkDerivation {
      name = "apple-color-emoji";
      src = inputs.apple-color-emoji;
      dontUnpack = true;
      nativeBuildInputs = [
        (pkgs.python3.withPackages (p: [
          p.fonttools
          p.uharfbuzz
        ]))
      ];
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        python3 ${addGsub} $src ${emojiSequences} $out/share/fonts/truetype/AppleColorEmoji.ttf
      '';
    };
}
