
--找CIP/CIFX同時存在的顧客
select * from cifx.tb_customer@cyberark_cifx a inner join
(select circi_key, disabled from cip_batch.vw_cust_key_mapping where circi_key is not null) b
on a.cif_verified_id = b.circi_key
where b.disabled is null
/