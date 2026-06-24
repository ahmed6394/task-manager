# Deployment & Monitoring Setup

## Infrastructure

### Machines
| Machine | Type | Storage | Purpose |
|---|---|---|---|
| app-server | t2.medium | 8 GiB | Runs the app + node_exporter |
| monitoring | t2.large | 12 GiB | Runs Prometheus, Grafana, Blackbox exporter |

### Required Inbound Ports (both machines)
| Port | Service |
|---|---|
| 22 | SSH |
| 3000 | Grafana |
| 9090 | Prometheus |
| 9100 | Node Exporter |
| 9115 | Blackbox Exporter |
| 30080 | App (NodePort) |

---

## 1. App Server — Deploy the App

### 1.1 Install dependencies
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k3s (single-node Kubernetes)
curl -sfL https://get.k3s.io | sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
```

### 1.2 Clone the repo
```bash
git clone https://github.com/ahmed6394/task-manager.git
cd task-manager
```

### 1.3 Create private values file
```bash
cat > helm/todo-app/values-dev.private.yaml <<EOF
backend:
  secrets:
    databaseUrl: "postgresql://todouser:todopass@postgres.todo.svc.cluster.local:5432/tododb"
EOF
```

### 1.4 Deploy with Helm
```bash
helm upgrade --install todo-app helm/todo-app \
  --namespace todo --create-namespace \
  -f helm/todo-app/values.yaml \
  -f helm/todo-app/values-dev.private.yaml
```

### 1.5 Verify
```bash
kubectl get pods -n todo
kubectl get deploy,svc -n todo
```

Access the app at: `http://<app-server-public-ip>:30080`

---

## 2. App Server — Install Node Exporter

### 2.1 Download and extract
Go to https://prometheus.io/download/ and copy the latest `node_exporter` Linux tarball URL, then:

```bash
wget <node_exporter_tarball_url>
tar -xvf node_exporter-*.tar.gz
rm node_exporter-*.tar.gz
mv node_exporter-*/ node_exporter
cd node_exporter
./node_exporter &   # note: binary is node_exporter not nodeexporter
```

### 2.2 Verify
Access: `http://<app-server-public-ip>:9100/metrics`

---

## 3. Monitoring Server — Install Blackbox Exporter

Follow the same steps as Node Exporter above using the `blackbox_exporter` tarball from https://prometheus.io/download/

```bash
cd blackbox_exporter
./blackbox_exporter &
```

Verify: `http://<monitoring-public-ip>:9115`

---

## 4. Monitoring Server — Install and Configure Prometheus

### 4.1 Download and extract
Follow the same steps using the `prometheus` tarball from https://prometheus.io/download/

### 4.2 Edit `prometheus.yml`
```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['<app-server-private-ip>:9100']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://<app-server-public-ip>:30080   # your app
          - https://github.com/ahmed6394/task-manager  # github repo
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115
```

### 4.3 Start Prometheus
```bash
cd prometheus
./prometheus &
```

### 4.4 Verify targets
Access: `http://<monitoring-public-ip>:9090/targets`
All targets should show **UP** in green.

---

## 5. Monitoring Server — Install and Configure Grafana

### 5.1 Install
```bash
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_11.6.0_amd64.deb
sudo dpkg -i grafana_11.6.0_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server
```

### 5.2 Login
Access: `http://<monitoring-public-ip>:3000`  
Default credentials: `admin` / `admin`

### 5.3 Add Prometheus as data source
1. Go to **Connections** → **Data Sources** → **Add new data source**
2. Select **Prometheus**
3. Set URL to: `http://localhost:9090`
4. Click **Save & Test** — should show "Successfully queried the Prometheus API"

### 5.4 Import Node Exporter dashboard
1. Go to **Dashboards** → **Import**
2. Enter dashboard ID: `1860`
3. Select your Prometheus data source
4. Click **Import**

### 5.5 Import Blackbox Exporter dashboard
1. Go to **Dashboards** → **Import**
2. Enter dashboard ID: `7587`
3. Select your Prometheus data source
4. Click **Import**