/* Research map: method -> application flow (D3 + d3-sankey).
   Data: research/flow/data.js (window.PAPERS). */
(function () {
const P = window.PAPERS;
const root = document.getElementById('research-flow');
if (!P || !root || !window.d3 || !d3.sankey) return;

const M=[{k:'S',name:'Statistical physics',lines:['Statistical physics'],nl:['Statistical','physics']},
         {k:'M',name:'Monte Carlo & classical heuristics',lines:['Monte Carlo &','classical heuristics'],nl:['Monte Carlo &','classical','heuristics']},
         {k:'Q',name:'Quantum, quantum-inspired & ML',lines:['Quantum, quantum-','inspired & ML'],nl:['Quantum,','quantum-','inspired & ML']}];
const A=[{k:'F',name:'Fundamental physics',lines:['Fundamental physics'],nl:['Fundamental','physics']},
         {k:'H',name:'Quantum hardware',lines:['Quantum hardware'],nl:['Quantum','hardware']},
         {k:'A',name:'Industrial & applied',lines:['Industrial & applied'],nl:['Industrial &','applied']}];
const col=k=>getComputedStyle(root).getPropertyValue('--c-'+k).trim();
const mName=Object.fromEntries(M.map(d=>[d.k,d.name])),aName=Object.fromEntries(A.map(d=>[d.k,d.name]));
const chart=document.getElementById('rf-chart'), panelEl=document.getElementById('rf-panel');
let sel=null;

const count=document.getElementById('rf-count'); if(count) count.textContent=P.length;

function links(){const out=[];M.forEach((m,i)=>A.forEach((a,j)=>{const v=P.filter(p=>p.m===m.k&&p.a===a.k).length;if(v)out.push({source:i,target:3+j,value:v,m:m.k,a:a.k});}));return out;}

function draw(){
  chart.innerHTML='';
  const W=chart.clientWidth;
  if(!W) return;
  const narrow=W<560;
  const fs=narrow?12.5:15, labW=narrow?112:Math.min(230,Math.max(170,W*.2));
  const H=Math.round(Math.max(380,Math.min(520,W*.48)));
  const svg=d3.select(chart).append('svg').attr('viewBox',`0 0 ${W} ${H}`).attr('role','img');
  svg.append('title').text('Flow of papers from method families to application areas');
  const x0=labW,x1=W-labW;
  svg.append('text').attr('class','rf-axis').attr('x',narrow?0:x0).attr('y',14).text('METHOD');
  svg.append('text').attr('class','rf-axis').attr('x',narrow?W:x1).attr('y',14).attr('text-anchor','end').text('APPLICATION');
  const sk=d3.sankey().nodeWidth(narrow?10:14).nodePadding(narrow?22:30).nodeSort(null).linkSort(null).extent([[x0,28],[x1,H-6]]);
  const g=sk({nodes:[...M,...A].map(d=>({...d})),links:links()});
  const gr=svg.append('g').attr('class',sel&&sel.type!=='all'?'rf-dim':'');
  gr.append('g').selectAll('path').data(g.links).join('path')
    .attr('class',d=>'rf-link'+(isOn(d)?' on':'')).attr('d',d3.sankeyLinkHorizontal())
    .attr('stroke',d=>col(d.m)).attr('stroke-width',d=>Math.max(2,d.width))
    .on('click',(e,d)=>pick({type:'cell',m:d.m,a:d.a}))
    .append('title').text(d=>`${mName[d.m]} → ${aName[d.a]}: ${d.value} papers`);
  const nd=gr.append('g').selectAll('g').data(g.nodes).join('g').attr('class',d=>'rf-node'+(nodeOn(d)?' on':''));
  nd.append('rect').attr('x',d=>d.x0).attr('y',d=>d.y0).attr('width',d=>d.x1-d.x0).attr('height',d=>Math.max(3,d.y1-d.y0)).attr('rx',2)
    .attr('fill',d=>d.index<3?col(d.k):col('app')).on('click',(e,d)=>pickNode(d));
  nd.each(function(d){
    const left=d.index<3, gx=left?d.x0-12:d.x1+12, anchor=left?'end':'start';
    const a=d3.select(this).append('a').attr('href','#rf-panel').attr('tabindex',0)
      .attr('aria-label',`Show ${d.value} papers: ${d.name}`)
      .on('click',e=>{e.preventDefault();pickNode(d);});
    const lines=(narrow&&d.nl)?d.nl:d.lines, n=lines.length+1, lh=fs*1.25;
    let y=(d.y0+d.y1)/2-(n-1)*lh/2+fs*.35;
    a.append('rect').attr('class','rf-hit').attr('x',left?gx-labW+8:gx-4).attr('y',y-fs).attr('width',labW-8).attr('height',n*lh+4).attr('rx',4);
    lines.forEach(t=>{a.append('text').attr('class','rf-name').attr('x',gx).attr('y',y).attr('text-anchor',anchor).style('font-size',fs+'px').text(t);y+=lh;});
    a.append('text').attr('class','rf-cnt').attr('x',gx).attr('y',y).attr('text-anchor',anchor).text(d.value+' papers');
  });
}
const isOn=d=>!sel?false:sel.type==='cell'?d.m===sel.m&&d.a===sel.a:sel.type==='m'?d.m===sel.k:sel.type==='a'?d.a===sel.k:false;
const nodeOn=d=>!!sel&&((sel.type==='m'&&d.index<3&&d.k===sel.k)||(sel.type==='a'&&d.index>=3&&d.k===sel.k));
function pickNode(d){pick(d.index<3?{type:'m',k:d.k}:{type:'a',k:d.k});}
function pick(s){sel=s;draw();panel(true);}
function closePanel(){sel=null;draw();panelEl.hidden=true;panelEl.innerHTML='';}

function panel(scroll){
  let list,title,color,sub;
  if(sel.type==='m'){list=P.filter(p=>p.m===sel.k);title=mName[sel.k];color=col(sel.k);sub='Method';}
  else if(sel.type==='a'){list=P.filter(p=>p.a===sel.k);title=aName[sel.k];color=col('app');sub='Application';}
  else if(sel.type==='cell'){list=P.filter(p=>p.m===sel.m&&p.a===sel.a);title=`${mName[sel.m]} → ${aName[sel.a]}`;color=col(sel.m);sub='Flow';}
  else{list=P;title='All papers';color=col('app');sub='Everything';}
  const yrs=list.map(p=>p.year);
  panelEl.hidden=false;
  panelEl.innerHTML=`<div class="rf-panel-head"><h2><span class="rf-swatch" style="background:${color}"></span>${esc(title)}</h2>
   <button type="button" class="rf-btn" id="rf-close" aria-label="Close paper list">Close</button></div>
   <p class="rf-meta"><span>${sub} · ${list.length} papers · ${Math.min(...yrs)}–${Math.max(...yrs)}</span>${sel.type!=='all'?'<button type="button" class="rf-btn" id="rf-reset">Show all papers</button>':''}</p>
   <ol>${list.map(p=>`<li><a href="https://arxiv.org/abs/${p.id}" target="_blank" rel="noopener">${esc(p.title)}</a>
   <span class="rf-sub"><span>${p.year}</span> · arXiv:${p.id} · ${esc(p.authors)}</span></li>`).join('')}</ol>`;
  const r=document.getElementById('rf-reset');if(r)r.onclick=()=>pick({type:'all'});
  document.getElementById('rf-close').onclick=closePanel;
  if(scroll)panelEl.scrollIntoView({behavior:'smooth',block:'nearest'});
}
const esc=s=>String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const all=document.getElementById('rf-all'); if(all) all.onclick=()=>pick({type:'all'});

const go=()=>{draw();};
if(document.fonts&&document.fonts.ready) document.fonts.ready.then(go); else go();
let t,lastW=0;new ResizeObserver(()=>{const w=chart.clientWidth;if(w===lastW)return;lastW=w;clearTimeout(t);t=setTimeout(draw,60);}).observe(chart);
})();
