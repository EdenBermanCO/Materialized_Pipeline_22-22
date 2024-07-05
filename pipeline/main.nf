#!/usr/bin/env nextflow
// hash:sha256:372c441dc3506b5d2fc7ff87c100c938855bf8a6057fcf8a86966035fe14eebe

nextflow.enable.dsl = 1

reads_to_fastqc_1 = channel.fromPath("../data/Reads/*", type: 'any', relative: true)
capsule_fast_qc_1_to_capsule_multi_qc_2_2 = channel.create()

// capsule - FastQC
process capsule_fast_qc_1 {
	tag 'capsule-5932041'
	container "registry.apps-s.codeocean.com/published/ea2b4c83-912e-4479-8f23-81a85bad768a:v1"

	cpus 1
	memory '8 GB'

	input:
	val path1 from reads_to_fastqc_1

	output:
	path 'capsule/results/*' into capsule_fast_qc_1_to_capsule_multi_qc_2_2

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=ea2b4c83-912e-4479-8f23-81a85bad768a
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	ln -s "/tmp/data/Reads/$path1" "capsule/data/$path1" # id: 8f026f23-03ca-4e1e-8260-f463f94220f7

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v1.0 "https://apps-s.codeocean.com/capsule-5932041.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_fast_qc_1_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - MultiQC
process capsule_multi_qc_2 {
	tag 'capsule-6215221'
	container "registry.apps-s.codeocean.com/published/c039dc32-bdfe-4ac9-8432-d82c12437ac0:v1"

	cpus 1
	memory '8 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/' from capsule_fast_qc_1_to_capsule_multi_qc_2_2.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=c039dc32-bdfe-4ac9-8432-d82c12437ac0
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v1.0 "https://apps-s.codeocean.com/capsule-6215221.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_multi_qc_2_args}

	echo "[${task.tag}] completed!"
	"""
}
