#include "stdio.h"

// 结果矩阵C
int C[30];
// 输入数据
int input_buffer[83];
int sparse_matmul();

int main() {
    FILE *infile, *outfile;

    // 数据读取
    infile = fopen("exp2-1.input", "rb");
    fread(input_buffer, 4, 83, infile);
    fclose(infile);
    
    int output_shape = sparse_matmul();
    
    // 输出
    outfile = fopen("exp2-1.out", "wb");
    fwrite(C, 4, output_shape, outfile);
    fclose(outfile);
    
    return 0;
}


int sparse_matmul() {

    // 稀疏矩阵乘法（CSR格式）
    // 参数说明：
    // values: 非零元素的值数组
    // col_indices: 非零元素的列索引数组
    // row_ptr: 行指针数组（长度为m+1）
    // B: 稠密矩阵（n行p列）
    // C: 结果矩阵（m行p列）
    // m, n, p: 矩阵维度
    // s：稀疏矩阵非零元个数

    int m = input_buffer[0];
    int n = input_buffer[1];
    int p = input_buffer[2];
    int s = input_buffer[3];

    int* values = &input_buffer[4];
    int* col_indices = &input_buffer[4 + s];
    int* row_ptr = &input_buffer[4 + s*2];
    int* B = &input_buffer[5 + s * 2 + m];

    // 初始化结果矩阵为全零
    for(int i = 0; i < m * p; i++) C[i] = 0;

    // 遍历稀疏矩阵的每一行
    for (int i = 0; i < m; i++) {
        // 当前行的非零元素范围：row_ptr[i] 到 row_ptr[i+1]-1
        int start = row_ptr[i];
        int end = row_ptr[i+1];
        
        // 遍历当前行的所有非零元素
        for (int j = start; j < end; j++) {
            // 获取当前非零元素的列索引和值
            int k = col_indices[j];  // 列号
            int val = values[j];  // 元素值
            
            // 将A[i][k]与B的第k行相乘，累加到C的第i行
            for (int l = 0; l < p; l++) {
                int c_val = C[i * p + l];
                c_val = c_val + val * B[k * p + l];
                C[i * p + l] = c_val;
            }
        }
    }
    return m * p;
}