# MiniStack Local Testing Harness

This directory provides a zero-cloud, zero-cost emulation harness to validate module integration, syntax, and execution plans using [MiniStack](https://ministack.org/) or LocalStack without creating real AWS resources or incurring cloud billing.

---

## Prerequisites

1. Docker Desktop installed and running.
2. Terraform CLI v1.5.0+.

---

## Quickstart Guide

1. Start MiniStack or LocalStack container:
   ```bash
   # Run MiniStack emulator container
   docker run --rm -it -p 4566:4566 ministack/ministack:latest
   ```

2. Initialize Terraform against the local emulator:
   ```bash
   cd local/ministack
   terraform init
   ```

3. Generate execution plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration locally:
   ```bash
   terraform apply -auto-approve
   ```

5. Destroy local resources when finished:
   ```bash
   terraform destroy -auto-approve
   ```
