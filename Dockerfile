FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .

# NEW STEP: Install Linux build dependencies for numpy, pandas, scipy, and scikit-learn
# build-essential provides gcc/g++, which are needed for compiling C/C++ extensions
# libgfortran5 is often required for SciPy/NumPy to use optimized linear algebra libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libgfortran5 \
        && rm -rf /var/lib/apt/lists/*

# The original failing step, which will now succeed
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 5000
CMD ["python","app.py"]