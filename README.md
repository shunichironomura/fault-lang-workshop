# Fault language workshop

Fault言語の紹介・演習で使うモデルとinstall scriptです。

## Setup

```bash
git clone https://github.com/shunichironomura/fault-lang-workshop.git
cd fault-lang-workshop
./install.sh
```

`install.sh`は次を行います。

- macOSではHomebrew、UbuntuではAPTを使ってZ3をinstall
- Fault v1.0.0のrelease binaryをdownloadし、checksumを検証
- `fault`を`~/.local/bin`へinstall
- `~/.faultrc`へZ3の設定を保存

`~/.local/bin`がPATHにない場合は、次をshellの設定へ追加してください。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

別のFault releaseを使う場合は環境変数で指定できます。

```bash
FAULT_VERSION=v1.0.0 ./install.sh
```

## Models

| File | 内容 |
| --- | --- |
| `examples/bathtub.fspec` | failure witnessを探す最小モデル |
| `examples/bathtub-plan.fspec` | synthesis slotを使った操作列の合成 |
| `examples/switch.fsystem` | state machine単体の最小モデル |
| `examples/satellite-power.fspec` | 人工衛星のstock/flowによる電力収支 |
| `examples/satellite-mission.fsystem` | 電力モデルをimportし、mode遷移からflowを呼ぶモデル |
| `exercises/command-sequence.fspec` | command sequence合成の小演習 |
| `solutions/command-sequence-55-two-slots.fspec` | 観測消費55、2 slots |
| `solutions/command-sequence-55-three-slots.fspec` | 観測消費55、3 slots |

## Run

```bash
fault -f examples/bathtub.fspec
fault -f examples/bathtub-plan.fspec
fault -f examples/switch.fsystem
fault lint -f examples/satellite-power.fspec
fault -f examples/satellite-mission.fsystem
fault -f exercises/command-sequence.fspec
```

中間表現だけを確認することもできます。

```bash
fault -f examples/bathtub.fspec -m ast
fault -f examples/bathtub.fspec -m ir
fault -f examples/bathtub.fspec -m smt
```

## References

- [Fault documentation](https://fault.tech/)
- [Fault installation](https://fault.tech/installation/)
- [Fault releases](https://github.com/Fault-lang/Fault/releases)
- [Z3 releases](https://github.com/Z3Prover/z3/releases)
