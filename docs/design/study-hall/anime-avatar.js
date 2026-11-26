// ================= avatar (anime / chibi) =================
const SKIN = ['#FFE8DA','#F8D9C4','#EBC2A2','#C99A76','#8F6449'];
const HAIRC = ['#2B2433','#4A3328','#7A4B33','#C58B5A','#EBCB8B','#E79AAF','#8FA6D8','#B9B6C9'];
const EYEC = ['#6B4130','#C27A2C','#3D6FB6','#3E8A63','#7E58B5','#B8354A'];
const TOPC = ['#6F7C8F','#2E3A59','#B4A89A','#3F5B4F','#C98B7A','#E8E1D6','#8E7CA8','#23232B'];
const HAIRS = [['long','بلند'],['wavy','موج‌دار'],['twin','دوگوشی'],['pony','دم‌اسبی'],['bob','چتری'],['bun','گوجه‌ای'],['wolf','ولف‌کات'],['spiky','تیغ‌تیغی'],['ahoge','شلخته']];
const EYES = [['sparkle','براق'],['calm','آروم'],['happy','خندون'],['wink','چشمک']];
const TOPS = [['hoodie','هودی'],['sweater','بافت'],['shirt','پیراهن'],['sailor','ملوانی']];
const ACCS = [['catphones','هدفون گربه'],['headphones','هدفون'],['glasses','عینک'],['bow','پاپیون'],['earrings','گوشواره']];
const me = { skin:0, hair:'long', hairC:5, eyes:'sparkle', eyeC:4, blush:true, acc:{ catphones:true, bow:false, earrings:true }, top:'hoodie', topC:5 };

const darken = (hex, k=.72) => '#' + [1,3,5].map(i => Math.round(parseInt(hex.substr(i,2),16)*k).toString(16).padStart(2,'0')).join('');
const lighten = (hex, k=.4) => '#' + [1,3,5].map(i => { const v = parseInt(hex.substr(i,2),16); return Math.round(v + (255-v)*k).toString(16).padStart(2,'0'); }).join('');

// shared defs (face clip + iris gradients), injected once
(function () {
  const d = document.createElement('div');
  d.innerHTML = `<svg width="0" height="0" style="position:absolute"><defs>
    <clipPath id="faceclip"><path d="M-32 -106 C-33 -142 33 -142 32 -106 C32 -86 20 -68 0 -64 C-20 -68 -32 -86 -32 -106Z"/></clipPath>
    ${EYEC.map((c,i)=>`<linearGradient id="iris${i}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${darken(c,.45)}"/><stop offset=".55" stop-color="${c}"/><stop offset="1" stop-color="${lighten(c,.55)}"/></linearGradient>`).join('')}
  </defs></svg>`;
  document.body.prepend(d.firstChild);
})();

const LASH = '#2A2230';
function eye(x, c) {
  const s = x < 0 ? -1 : 1, st = c.eyes === 'wink' ? (x > 0 ? 'happy' : 'sparkle') : c.eyes;
  if (st === 'happy') return `<path d="M${x-8} -88 Q${x} -99 ${x+8} -88" stroke="${LASH}" stroke-width="3" fill="none" stroke-linecap="round"/>`;
  const calm = st === 'calm', cy = calm ? -87 : -90, ry = calm ? 7 : 10;
  let g = `<ellipse cx="${x}" cy="${cy}" rx="8" ry="${ry}" fill="#fff"/>`;
  g += `<ellipse cx="${x}" cy="${cy+1}" rx="6.6" ry="${ry-1}" fill="url(#iris${c.eyeC})"/>`;
  g += `<ellipse cx="${x}" cy="${cy+2}" rx="3" ry="${calm?3.6:4.8}" fill="${darken(EYEC[c.eyeC],.3)}"/>`;
  g += `<circle cx="${x-2.6}" cy="${cy-3.6}" r="${calm?2.2:2.9}" fill="#fff"/><circle cx="${x+2.8}" cy="${cy+4.4}" r="1.3" fill="#fff" opacity=".9"/>`;
  const top = cy - ry + 1;
  g += `<path d="M${x-s*7.5} ${top+3} Q${x+s*1.5} ${top-(calm?1.5:3)} ${x+s*8.5} ${top+2}" stroke="${LASH}" stroke-width="2.8" fill="none" stroke-linecap="round"/>`;
  g += `<path d="M${x+s*8.2} ${top+2} q${s*3} 0 ${s*4.4} 2.6" stroke="${LASH}" stroke-width="2.2" fill="none" stroke-linecap="round"/>`;
  g += `<path d="M${x-4.5} ${cy+ry+.6} Q${x} ${cy+ry+1.4} ${x+4.5} ${cy+ry+.6}" stroke="${LASH}" stroke-width="1" opacity=".45" fill="none"/>`;
  return g;
}

const BANGS = {
  long:  'M-37 -96 C-42 -152 42 -152 37 -96 L33 -92 L30 -108 L24 -96 L18 -114 L12 -99 L4 -116 L-2 -101 L-10 -116 L-16 -99 L-22 -112 L-28 -94 L-31 -106 L-37 -88 Z',
  blunt: 'M-37 -96 C-42 -152 42 -152 37 -96 L34 -102 L28 -100 L22 -107 L14 -102 L6 -108 L-2 -102 L-10 -108 L-18 -102 L-26 -107 L-32 -100 L-37 -98Z',
  swept: 'M-37 -96 C-42 -152 42 -152 37 -96 L33 -104 L28 -96 L24 -112 C12 -112 -4 -106 -18 -96 L-14 -108 C-22 -104 -28 -98 -32 -90 L-37 -86Z',
  spiky: 'M-36 -96 L-42 -122 L-32 -122 L-35 -142 L-21 -134 L-15 -154 L-3 -141 L8 -157 L14 -140 L28 -148 L28 -132 L41 -130 L36 -96 L34 -108 L28 -100 L24 -114 L16 -102 L10 -118 L2 -104 L-6 -118 L-12 -102 L-20 -114 L-26 -100 L-32 -110Z',
  wolf:  'M-37 -96 C-42 -152 42 -152 37 -96 L35 -86 L30 -104 L26 -92 L20 -112 L14 -94 L6 -112 L0 -96 L-6 -112 L-14 -94 L-20 -112 L-26 -92 L-30 -104 L-35 -84Z',
};
const BACK = {
  long:  'M-40 -104 C-48 -158 48 -158 40 -104 L46 -32 L38 -40 L34 -26 L24 -36 L0 -30 L-24 -36 L-34 -26 L-38 -40 L-46 -32 Z',
  wavy:  'M-40 -104 C-48 -158 48 -158 40 -104 Q51 -88 42 -74 Q53 -58 42 -42 Q47 -28 34 -24 L-34 -24 Q-47 -28 -42 -42 Q-53 -58 -42 -74 Q-51 -88 -40 -104Z',
  bob:   'M-40 -104 C-48 -158 48 -158 40 -104 L42 -64 L34 -70 L28 -60 L-28 -60 L-34 -70 L-42 -64Z',
  cap:   'M-39 -104 C-47 -158 47 -158 39 -104 L38 -82 L-38 -82Z',
  wolf:  'M-40 -104 C-48 -158 48 -158 40 -104 L43 -68 L35 -74 L30 -60 L18 -70 L0 -64 L-18 -70 L-30 -60 L-35 -74 L-43 -68Z',
};
const SIDE = (len) => `M-37 -100 L-41 ${len} L-35 ${len+8} L-31 ${len-2} L-29 -96Z M37 -100 L41 ${len} L35 ${len+8} L31 ${len-2} L29 -96Z`;

function hairParts(h) {
  switch (h) {
    case 'long':  return { back: BACK.long, front: BANGS.long, side: SIDE(-58) };
    case 'wavy':  return { back: BACK.wavy, front: BANGS.swept, side: SIDE(-62) };
    case 'twin':  return { back: BACK.cap, front: BANGS.long, side: SIDE(-70), extra: 'twin' };
    case 'pony':  return { back: BACK.cap, front: BANGS.swept, side: SIDE(-74), extra: 'pony' };
    case 'bob':   return { back: BACK.bob, front: BANGS.blunt, side: SIDE(-70) };
    case 'bun':   return { back: BACK.cap, front: BANGS.blunt, extra: 'bun' };
    case 'wolf':  return { back: BACK.wolf, front: BANGS.wolf };
    case 'spiky': return { back: BACK.cap, front: BANGS.spiky };
    case 'ahoge': return { back: BACK.cap, front: BANGS.wolf, extra: 'ahoge' };
  }
}

function avatar(c, sil) {
  const f = k => sil || k;
  const skin = SKIN[c.skin], hc = HAIRC[c.hairC], tc = TOPC[c.topC], hd = darken(hc, .8), acc = c.acc || {};
  const H = hairParts(c.hair);
  let g = '';
  // extras behind
  if (H.extra === 'twin') g += `<path d="M-34 -124 C-66 -120 -70 -66 -56 -30 L-50 -46 L-46 -28 C-40 -66 -40 -102 -30 -114Z M34 -124 C66 -120 70 -66 56 -30 L50 -46 L46 -28 C40 -66 40 -102 30 -114Z" fill="${f(hd)}"/>`;
  if (H.extra === 'pony') g += `<path d="M16 -142 C60 -152 64 -94 50 -50 L45 -66 L38 -50 C48 -90 38 -122 12 -130Z" fill="${f(hd)}"/>`;
  if (H.extra === 'bun') g += `<circle cx="0" cy="-152" r="15" fill="${f(hd)}"/>`;
  g += `<path d="${H.back}" fill="${f(hd)}"/>`;
  // body
  g += `<path d="M-46 0 C-46 -36 -28 -52 0 -52 C28 -52 46 -36 46 0 Z" fill="${f(tc)}"/>`;
  if (!sil) {
    if (c.top === 'hoodie') g += `<path d="M-24 -50 C-18 -34 18 -34 24 -50" stroke="${darken(tc,.82)}" stroke-width="7" fill="none" stroke-linecap="round"/><path d="M-7 -38 v16 M7 -38 v16" stroke="${lighten(tc,.6)}" stroke-width="2.2" stroke-linecap="round"/>`;
    if (c.top === 'sweater') g += `<path d="M-12 -51 C-8 -43 8 -43 12 -51" stroke="${darken(tc,.8)}" stroke-width="5" fill="none"/><path d="M-42 -16 H42" stroke="${darken(tc,.88)}" stroke-width="4"/><path d="M-20 -30 l4 4 l4 -4 l4 4 l4 -4 l4 4 l4 -4 l4 4 l4 -4 l4 4" stroke="${lighten(tc,.5)}" stroke-width="1.6" fill="none"/>`;
    if (c.top === 'shirt') g += `<path d="M-13 -52 L-1 -38 L-6 -54Z M13 -52 L1 -38 L6 -54Z" fill="#fff"/><path d="M0 -40 l-3.5 4 l3.5 18 l3.5 -18z" fill="#C94B4B"/>`;
    if (c.top === 'sailor') g += `<path d="M-30 -50 L0 -22 L30 -50 L42 -26 L0 -10 L-42 -26Z" fill="#2E3A59"/><path d="M-36 -40 L0 -16 L36 -40" stroke="#fff" stroke-width="2" fill="none"/><path d="M0 -24 l-9 -5 v10z M0 -24 l9 -5 v10z" fill="#C94B4B"/><circle cx="0" cy="-24" r="2.6" fill="#A83A3A"/>`;
  }
  g += `<rect x="-7" y="-68" width="14" height="18" rx="5" fill="${f(sil ? skin : darken(skin,.9))}"/>`;
  g += `<circle cx="-31" cy="-94" r="5" fill="${f(skin)}"/><circle cx="31" cy="-94" r="5" fill="${f(skin)}"/>`;
  g += `<path d="M-32 -106 C-33 -142 33 -142 32 -106 C32 -86 20 -68 0 -64 C-20 -68 -32 -86 -32 -106Z" fill="${f(skin)}"/>`;
  if (!sil) {
    // shadow under bangs
    g += `<g clip-path="url(#faceclip)"><path d="${H.front}" transform="translate(0,4)" fill="${darken(skin,.86)}" opacity=".55"/></g>`;
    if (acc.earrings) g += `<circle cx="-31" cy="-87" r="2.4" fill="#E9C46A"/><circle cx="31" cy="-87" r="2.4" fill="#E9C46A"/>`;
    g += eye(-14, c) + eye(14, c);
    if (c.blush) g += `<ellipse cx="-20" cy="-78" rx="6" ry="3" fill="#F28A9B" opacity=".38"/><ellipse cx="20" cy="-78" rx="6" ry="3" fill="#F28A9B" opacity=".38"/>`
      + [-23,-20,-17,17,20,23].map(x=>`<path d="M${x} -80 l-1.6 3" stroke="#E8707F" stroke-width="1" opacity=".7"/>`).join('');
    g += `<path d="M.6 -81 l-1 2" stroke="${darken(skin,.7)}" stroke-width="1.2" stroke-linecap="round"/>`;
    g += c.eyes === 'happy' ? `<path d="M-5 -74 Q0 -66 5 -74Z" fill="#9B4A4A"/><path d="M-3 -70 Q0 -68 3 -70" stroke="#E77" stroke-width="1.6" fill="none"/>`
                            : `<path d="M-4.5 -73.5 Q0 -70 4.5 -73.5" stroke="#9B4A4A" stroke-width="1.8" fill="none" stroke-linecap="round"/>`;
  }
  if (H.side) g += `<path d="${H.side}" fill="${f(hc)}"/>`;
  g += `<path d="${H.front}" fill="${f(hc)}"/>`;
  if (H.extra === 'ahoge') g += `<path d="M2 -144 C4 -166 22 -168 18 -154 C14 -160 8 -158 6 -144Z" fill="${f(hc)}"/>`;
  if (!sil) {
    // anime shine ring + strands
    g += `<path d="M-25 -128 Q-14 -136 -4 -132 M4 -133 Q14 -136 25 -128" stroke="${lighten(hc,.55)}" stroke-width="3.4" fill="none" stroke-linecap="round" opacity=".75"/>`;
    g += `<path d="M-10 -142 L-14 -118 M12 -142 L16 -120" stroke="${darken(hc,.85)}" stroke-width="1.2" opacity=".5"/>`;
    if (H.extra === 'twin') g += `<circle cx="-34" cy="-124" r="4.5" fill="#F4A7B9"/><circle cx="34" cy="-124" r="4.5" fill="#F4A7B9"/>`;
    if (acc.bow) g += `<g transform="translate(24,-136) rotate(18)"><path d="M0 0 L-12 -8 L-12 8Z M0 0 L12 -8 L12 8Z" fill="#E85D75"/><circle r="3.4" fill="#C94B62"/></g>`;
    if (acc.glasses) g += `<rect x="-24" y="-99" width="19" height="16" rx="6" stroke="#3A2E3A" stroke-width="1.8" fill="#ffffff18"/><rect x="5" y="-99" width="19" height="16" rx="6" stroke="#3A2E3A" stroke-width="1.8" fill="#ffffff18"/><path d="M-5 -92 h10" stroke="#3A2E3A" stroke-width="1.8"/>`;
  }
  if (acc.headphones || acc.catphones) {
    const band = sil || (acc.catphones ? '#F2C4D0' : '#3A3D52'), cup = sil || (acc.catphones ? '#FFF1F4' : '#E9E6EF');
    if (acc.catphones) g += `<path d="M-30 -136 L-34 -160 L-16 -146Z M30 -136 L34 -160 L16 -146Z" fill="${band}"/>${sil?'':`<path d="M-29 -140 L-31 -153 L-21 -146Z M29 -140 L31 -153 L21 -146Z" fill="#E88AA2"/>`}`;
    g += `<path d="M-37 -96 C-42 -160 42 -160 37 -96" stroke="${band}" stroke-width="6" fill="none" stroke-linecap="round"/>`;
    g += `<rect x="-45" y="-108" width="13" height="25" rx="6.5" fill="${cup}"/><rect x="32" y="-108" width="13" height="25" rx="6.5" fill="${cup}"/>`;
    if (!sil && acc.catphones) g += `<circle cx="-38.5" cy="-95.5" r="3" fill="#F2A7B9"/><circle cx="38.5" cy="-95.5" r="3" fill="#F2A7B9"/>`;
  }
  return g;
}
