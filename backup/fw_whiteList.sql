select '1',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port in('20','21') and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '2',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '25' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '3',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '53' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '4',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '80' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '5',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '110' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '6',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '123' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '7',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '143' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '8',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '443' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '9',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '1080' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;
select '10',gi.org_id,gi.vsys_id,ins.status,gi.gip,gi.status,fw.src,fw.src_port,fw.dst,fw.dst_port,fw.from,fw.action from `instance` ins left join fw_policy fw on ins.vsys_id = fw.vsys_id left join `gip#instance` gi on fw.vsys_id = gi.vsys_id and fw.dst = gi.gip where gi.status in ('ATTACHED','DETACHED') and fw.src in ('any','0.0.0.0/0') and fw.dst_port = '8080' and fw.protocol != 'udp' and fw.from like '%INTERNET' and fw.action = 'Accept' order by vsys_id;