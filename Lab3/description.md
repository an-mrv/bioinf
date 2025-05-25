# Домашнее задание 3

Minimap2, Nextflow

Работаю на macOS 14.5

## Пайплайн на bash

Взяла геном Escherichia coli - [Escherichia coli](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR33602302&display=download)

Скачала референсный геном [e.coli](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000005845.2/)

Скрипт [`bash/script.sh`](./bash/script.sh)

Результат работы пайплайна в директории [`bash`](./bash)

## Фреймворк Nextflow

### Установка **Nextflow**
- `brew install openjdk` - необходимо установить openjdk, если не установлена
- `curl -s https://get.nextflow.io | bash`
- `chmod +x nextflow`
- `sudo mv nextflow /usr/local/bin/`

### Тестовый пайплайн (“Hello world”)
- код в файле [`nextflow_framework/hello_world/hello.nf`](./nextflow_framework/hello_world/hello.nf)
- запуск: `nextflow run nextflow_framework/hello_world/hello.nf`
- логи запуска в директории [`nextflow_framework/hello_world`](./nextflow_framework/hello_world)

### Пайплайн оценки качества картирования
- код в файле [`nextflow_framework/alignment/alignment_pipeline.nf`](./nextflow_framework/alignment/alignment_pipeline.nf)
- запуск: `nextflow run alignment_pipeline.nf`
- результат работы пайплайна и логи запуска в директории [`nextflow_framework/alignment`](./nextflow_framework/alignment)

### Визуализацию пайплайна

- для визуализации нужно добавить флаг `-with-dag` при запуске пайплайна:
  - `nextflow run alignment_pipeline.nf -with-dag dag.png`
- визуализация в файле [`nextflow_framework/alignment/dag.png`](./nextflow_framework/alignment/dag.png)

Отличие полученной визуализации от блок-схемы алгоритма: Анализ исходного генома через `fastqc` и процесс с сообщением о завершении пайплайна запускаются параллельно основному пайплайну.

