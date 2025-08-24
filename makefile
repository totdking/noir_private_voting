compile:
	@echo "nargo compilation start"
	@nargo compile
	@echo "nargo compilation completed"

check:
	@echo "creating Prover.toml"
	@nargo check
	@echo "Prover.toml created in target folder"

check-overwrite:
	@echo "overwrite previous Prover.toml"
	@nargo check --overwrite
	@echo "overwrite completed"

execute:
	@echo "witness being created"
	@nargo execute
	@echo "witness created as project_name.gz"

prove:
	@bb prove -b ./target/private_voting.json -w ./target/private_voting.gz -o ./target

write_vk:
	@bb write_vk -b ./target/private_voting.json -o ./target

verify:
	@bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs