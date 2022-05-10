DOCKER_NETWORK = dockerhadoop_default
ENV_FILE = hadoop.env
current_branch := $(shell git rev-parse --abbrev-ref HEAD)
build:
	lima nerdctl build -t cjoongho/hadoop-base:$(current_branch) ./base
	lima nerdctl build -t cjoongho/hadoop-namenode:$(current_branch) ./namenode
	lima nerdctl build -t cjoongho/hadoop-datanode:$(current_branch) ./datanode
	lima nerdctl build -t cjoongho/hadoop-resourcemanager:$(current_branch) ./resourcemanager
	lima nerdctl build -t cjoongho/hadoop-nodemanager:$(current_branch) ./nodemanager
	#lima nerdctl build -t cjoongho/hadoop-historyserver:$(current_branch) ./historyserver
	#lima nerdctl build -t cjoongho/hadoop-submit:$(current_branch) ./submit

wordcount:
	docker build -t hadoop-wordcount ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(current_branch) hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(current_branch) hdfs dfs -copyFromLocal /opt/hadoop-2.7.4/README.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(current_branch) hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(current_branch) hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(current_branch) hdfs dfs -rm -r /input
