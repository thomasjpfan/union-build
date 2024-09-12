#syntax=docker/dockerfile:1.9
ARG PYTHON_VERSION

FROM ghcr.io/astral-sh/uv:0.4.9 as uv
FROM python:${PYTHON_VERSION}-slim-bookworm

RUN id -u flytekit || useradd --create-home --shell /bin/bash flytekit
RUN chown -R flytekit /root && chown -R flytekit /home

WORKDIR /root

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH=/root \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    FLYTE_SDK_RICH_TRACEBACKS=0

ARG UNION_VERSION
RUN --mount=type=cache,sharing=locked,mode=0777,target=/root/.cache/uv,id=uv \
    --mount=from=uv,source=/uv,target=/usr/bin/uv \
    uv venv $VIRTUAL_ENV && \
    uv pip install --python /opt/venv union

USER flytekit

