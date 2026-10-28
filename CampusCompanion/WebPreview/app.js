const files=[['CampusCompanion.xcodeproj','Initial Commit','last month'],['CampusCompanion','M6 Image & Loc','yesterday'],['TSA','github desktop','last month'],['.gitignore','Complete Campus Companion welcome s...','last month']];
const list=document.querySelector('#file-list');
function renderFiles(filter=''){list.innerHTML=files.filter(f=>f[0].toLowerCase().includes(filter.toLowerCase())).map(f=>`<div class="file-row"><span class="folder-icon">${f[0]==='.gitignore'?'▱':'■'}</span><span class="file-name">${f[0]}</span><span class="file-message">${f[1]}</span><span class="file-time">${f[2]}</span></div>`).join('')||'<div class="file-row"><span class="file-name">No matching files</span></div>'}
renderFiles();
const toast=document.querySelector('#toast');
function notify(message){toast.textContent=message;toast.classList.add('show');setTimeout(()=>toast.classList.remove('show'),1800)}
document.querySelector('#branch-button').addEventListener('click',()=>document.querySelector('#branch-menu').classList.toggle('open'));
document.querySelectorAll('.branch-menu button').forEach(button=>button.addEventListener('click',()=>{document.querySelector('#branch-button span').textContent=button.textContent.trim().replace('✓','');document.querySelector('#branch-menu').classList.remove('open');notify(`Switched to ${button.textContent.trim().replace('✓','')}`)}));
document.querySelector('#file-search').addEventListener('input',e=>renderFiles(e.target.value));
document.querySelector('#top-search').addEventListener('keydown',e=>{if(e.key==='Enter')notify(`Searching for “${e.target.value||'repository'}”`)});
document.querySelector('#code-button').addEventListener('click',()=>notify('Clone options opened'));
document.querySelectorAll('.copilot-actions button').forEach(button=>button.addEventListener('click',()=>notify(button.textContent.trim())));
document.querySelectorAll('.main-nav a').forEach(link=>link.addEventListener('click',e=>{e.preventDefault();document.querySelectorAll('.main-nav a').forEach(item=>item.classList.remove('active'));link.classList.add('active');notify(`${link.textContent.trim()} selected`)}));
