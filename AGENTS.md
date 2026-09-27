# AGENTS.md

이 저장소는 Terraform 으로 GCP 인프라를 관리하는 IaC 저장소입니다. AI 에이전트가 작업할 때 아래 규칙을 지킵니다.

## 이 저장소

- 신규 GKE 구축은 승인된 ADR-0014에 따라 `05-bootstrap`, `10-network`, `11-vpn`, `20-gke`, `21-cloud-sql`, `30-service-foundation`, `40-edge`를 사용합니다. root에 직접 선언하고 서비스 운영을 Terraform provisioner로 감싸지 않습니다.
- 기존 Cloud Run 네 root와 모듈은 기존 환경 관리용으로 보존합니다. 신규 root에 기존 State prefix를 재사용하지 않습니다. 신규 prefix는 `gke/<project>/<env>/<layer>/<target>`이며 데이터는 업무 복구 단위별로 분리합니다.
- 신규 secret 값은 ephemeral/write-only 입력 또는 별도 운영 경로만 사용합니다. Secret 버전, DMS endpoint/task, Kubernetes/Helm 자원은 신규 Terraform 범위 밖입니다.
- 신규 root의 비밀 없는 출력 계약은 운영자가 선택한 입력 파일로 전달합니다. 양쪽 클라우드 State를 서로 참조하거나 정상 절차에서 `-target`을 요구하지 않습니다.
- 전체 구축 절차와 설명 문서는 사용자 지정 `AWS-2Team-Personal/project-scrap`에 보관합니다. 아래 기존 팀 문서 경로 규칙보다 현재 사용자 지정 위치를 우선합니다.

- `modules/`: 재사용 모듈 (`network`, `vpn`). 네트워크 모듈의 Terraform 호출 이름은 기존 State 주소를 유지하도록 `backbone`을 사용합니다.
- `00-network`, `01-vpn`, `02-registry-iam`, `03-load-balancer`: 레이어 루트. 앞 번호가 배포 순서이고 각자 별도의 GCS State prefix를 가집니다. `03-load-balancer` 적용 전에 Cloud Run 서비스를 CLI로 배포합니다.
- 배포 순서와 명령은 `README.md` 에 있습니다.

## 규칙

### 1. 목적을 잊지 않는다 (가장 중요)

Terraform 의 목적은 인프라를 프로비저닝하고 코드로 관리하는 것입니다. 기술적으로 "가능한 것"과 이 저장소에서 "해야 하는 것"은 다릅니다. 목적에서 벗어난 기능을 Terraform 으로 구현하지 않습니다. 판단이 서지 않으면 만들지 말고 물어봅니다.

### 2. 요청한 것만, 하나씩 만든다

사용자가 이번 요청에서 명시한 리소스만 만듭니다. 요청하지 않은 것을 스스로 덧붙이지 않습니다.

- 예: Artifact Registry 를 요청받으면 Artifact Registry 만 만듭니다. GitHub 연동, IAM 역할, 실행 스크립트, 부가 정책 같은 것은 사용자가 따로 요청하기 전에는 만들지 않습니다.
- 판단 기준: 그 리소스가 사용자의 이번 요청 문장에 있는가. 없으면 만들지 않습니다. 필요해 보여도 먼저 물어보고, 승인 전에는 만들지 않습니다.

### 3. 리소스 이름과 주소는 한번 정하면 바꾸지 않는다

이미 만든 리소스의 Terraform 주소(예: `google_artifact_registry_repository.app`)와 이름을 수정하지 않습니다. 주소를 바꾸면 Terraform 이 기존 자원을 삭제하고 새로 만듭니다(destroy 후 recreate). 데이터 손실과 재생성의 원인입니다.

- 이름 변경이 정말 불가피하면 그냥 rename 하지 말고 `moved` 블록으로 처리하며, 실행 전에 사용자에게 먼저 알립니다.

### 4. 최소로 구성한다

모르는 부분을 넓게 잡아 크게 설계하지 않습니다. 이번 요청에 필요한 최소 구성만 만듭니다. 넓은 추측 설명 대신, 확인된 최소 범위만 다룹니다. 작업 시 ponytail 스킬을 사용합니다.

ponytail 스킬 설치 (Claude Code):

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

### 5. GCP 자격증명은 ADC로만 사용한다

GCP 자격증명(서비스 계정 키, 액세스 토큰, 갱신 토큰 등)을 환경변수나 도구로 직접 읽거나 다루지 않습니다. gcloud 및 ADC의 자격증명 파일을 조회하거나 추출하지 않고, `README.md` 의 인증 절차로 설정한 ADC(Application Default Credentials)를 통해서만 Terraform 인증에 사용합니다.

### 6. 억지로 목적을 이루지 않는다

목적을 달성하려고 우회나 편법을 쓰지 않습니다. 정공법으로 안 되면 멈추고 사용자에게 알립니다.

### 7. 구성 전에 목적을 확인하고 검토한다

무언가를 만들고 싶을 때, 먼저 그게 왜 필요한지 목적을 사용자에게 묻습니다. 브레인스토밍 스킬(superpowers)로 정말 필요한 기능인지 검토한 뒤에 만듭니다. 검토 없이 바로 구성하지 않습니다.

### 8. 시크릿을 GitHub 에 올리지 않는다

`.env` 와 env 계열 파일, GCP 자격증명은 GitHub 에 커밋하거나 푸시하지 않습니다. env 계열 파일은 `.gitignore` 로 무시하고, `.githooks/pre-commit` 훅이 커밋 단계에서 차단합니다. `.env.example` 은 예외이며 실제 비밀값을 넣지 않습니다. 훅은 env 파일 이름을 검사하며 모든 파일의 비밀값을 탐지하지는 않습니다.

훅 활성화 (클론 후 한 번):

```
git config core.hooksPath .githooks
```

### 9. 레이어 디렉터리는 배포 순서대로 번호를 붙인다

레이어 루트는 `NN-<이름>`(예: `00-network`, `01-vpn`)으로 만들고 앞 번호가 배포 순서입니다. 새 레이어를 추가하면 의존성에 맞는 번호를 붙이고, 배포 순서와 명령을 `README.md` 에 갱신합니다.

### 10. 새 모듈과 레이어는 network 규약을 따른다

`modules/network` 와 `00-network` 를 기준으로 통일합니다. 혼자 다른 규격으로 만들지 않습니다.

- 이름: 루트에서 `local.name_prefix = "${var.project}-${var.env}-dr"` 를 만들어 모듈에 `name` 으로 넘기고, 모듈은 `<name>-<suffix>` 로 조립합니다. 전체 이름을 하드코딩하지 않습니다.
- 값: 구체값(리소스 목록, 크기 등)은 tfvars 에 두고 `main.tf` 는 변수만 넘깁니다. main.tf 에 값을 하드코딩하지 않습니다.
- 라벨: 리소스 이름은 `name` 으로 지정하고 `environment`, `project`, `managed_by` 는 provider `default_labels` 로 자동 적용합니다. 라벨을 지원하는 리소스에만 적용됩니다.
- backend: 빈 `backend "gcs" {}` 에 `envs/<env>/backend.hcl` 을 주입합니다. State는 레이어별 `prefix` 로 분리하며, 현재 dev 환경은 `dev/backbone`, `dev/vpn` 을 사용합니다.
- versions: `required_version` 과 provider 버전을 다른 레이어와 맞춥니다.

### 11. 팀 문서는 다른 팀원이 같은 조건으로 실행할 수 있게 작성한다

- 명령의 작업 디렉터리는 저장소 루트를 기준으로 합니다. 클론 위치가 필요하면 `$HOME/work/gcp-infra` 같은 임의의 예시임을 명시하고, 실제 작성자의 사용자명·PC 절대경로·도구 설치 경로를 넣지 않습니다.
- 경로처럼 자유롭게 바꿀 수 있는 값과 배포 결과를 결정하는 값을 구분합니다. 프로젝트·리전·State 버킷/prefix·CIDR·ASN·리소스 이름은 팀 합의값 또는 의미가 드러나는 placeholder로 설명합니다. 기존 리소스 이름이나 State를 문서 일반화를 이유로 변경하지 않습니다.
- 필수 셸·도구 버전·인증·권한·환경 입력값과 신규/기존 환경의 차이를 적습니다. 같은 코드·입력값·State를 사용하는 재현 기준을 설명하고, 특정 PC나 특정 채팅의 선행 작업을 암묵적으로 가정하지 않습니다.
- 문서 링크는 저장소 내부 상대경로나 팀이 접근 가능한 공유 URL을 사용합니다. 개인 문서 저장소나 작성자의 로컬 폴더에 의존하지 않습니다.
- 문서 변경 후 숨김·미추적 문서를 포함한 저장소 전체 문서에서 개인 절대경로, 사용자명, 저장소 밖 로컬 링크, 설명 없는 로컬 환경 전제를 검색합니다. 상대 링크의 대상과 명령의 작업 디렉터리·입력값도 확인합니다.
- 실행 절차와 실제 실행 기록을 구분합니다. 정적 검사만 했다면 정적 검사로 보고하고, 누락된 절차나 실행하지 않은 배포를 재현 완료로 표현하지 않습니다.
