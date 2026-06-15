<template>
  <div class="experiment-detail">
    <div class="progress-wrapper">
      <el-card class="progress-indicator" :body-style="{ padding: '0' }">
        <div class="progress-content">
          <div class="progress-left">
            <div class="progress-main">
              <h2>实验进度</h2>
              <el-tag size="small" type="success" class="progress-tag">{{ totalCompleted }}/{{ totalQuestions }}</el-tag>
            </div>
            <div class="progress-steps">
              <div class="step-item" :class="{ 'completed': isStepCompleted('choice') }">
                <span class="step-title">选择题</span>
                <el-tag size="small" :type="isStepCompleted('choice') ? 'success' : 'info'" class="step-tag">
                  {{ choiceCompleted }}/{{ questions.choice.length }}
                </el-tag>
              </div>
              <div class="step-divider">></div>
              <div class="step-item" :class="{ 'completed': isStepCompleted('fill') }">
                <span class="step-title">填空题</span>
                <el-tag size="small" :type="isStepCompleted('fill') ? 'success' : 'info'" class="step-tag">
                  {{ fillCompleted }}/{{ questions.fill.length }}
                </el-tag>
              </div>
              <div class="step-divider">></div>
              <div class="step-item" :class="{ 'completed': isStepCompleted('coding') }">
                <span class="step-title">编程题</span>
                <el-tag size="small" :type="isStepCompleted('coding') ? 'success' : 'info'" class="step-tag">
                  {{ codingCompleted }}/{{ questions.coding.length }}
                </el-tag>
              </div>
            </div>
          </div>
          <div class="last-saved" v-if="lastSaved">
            上次保存: {{ formatTime(lastSaved) }}
          </div>
          <div class="score-display" v-if="totalScore > 0">
            <el-alert type="success" show-icon :closable="false">
              🎉 本次实验总得分：<strong>{{ totalScore }}</strong> 分
            </el-alert>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 🔽 实验信息展示卡片 -->
    <el-card class="experiment-info" style="margin: 20px 0;">
      <div class="experiment-header">
        <h2 style="margin-bottom: 10px;">{{ experimentData.title || '实验标题未定义' }}</h2>
        <p style="color: #666;">{{ experimentData.description || '暂无实验描述' }}</p>
      </div>
    </el-card>



    <div class="questions-container">
      <!-- 选择题 -->
      <div class="question-section" id="choice-section">
        <h2>选择题</h2>
        <div v-for="(q, index) in questions.choice" :key="index">
          <el-card class="question-card">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <h3>{{ q.description }}</h3>
              <el-tag v-if="q.score !== undefined" type="info" size="small">
                {{ q.score }} 分
              </el-tag>
            </div>
            <el-radio-group v-model="q.selected" @change="handleAnswerChange('choice', q)">
              <el-radio v-for="opt in q.options" :key="opt.id" :label="opt.id">
                {{ opt.text }}
              </el-radio>
            </el-radio-group>
            <div v-if="q.isCorrect !== undefined" class="result-indicator">
              <el-tag :type="q.isCorrect ? 'success' : 'danger'">
                {{ q.isCorrect ? '正确' : '错误' }}
              </el-tag>
              <span v-if="!q.isCorrect" class="correct-answer">
                正确答案: {{ q.correctAnswer }}
              </span>
            </div>
          </el-card>
        </div>
      </div>

      <!-- 填空题 -->
      <div class="question-section" id="fill-section">
        <h2>填空题</h2>
        <div v-for="(q, index) in questions.fill" :key="index">
          <el-card class="question-card">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <h3>{{ q.description }}</h3>
              <el-tag v-if="q.score !== undefined" type="info" size="small">
                {{ q.score }} 分
              </el-tag>
            </div>
            <el-input
              v-model="q.answer"
              placeholder="请输入答案"
              @input="handleAnswerChange('fill', q)"
            />
            <div v-if="q.isCorrect !== undefined" class="result-indicator">
              <el-tag :type="q.isCorrect ? 'success' : 'danger'">
                {{ q.isCorrect ? '正确' : '错误' }}
              </el-tag>
              <span v-if="!q.isCorrect" class="correct-answer">
                正确答案: {{ q.correctAnswer }}
              </span>
            </div>
          </el-card>
        </div>
      </div>

      <!-- 编程题 -->
      <div class="question-section" id="coding-section">
        <h2>编程题</h2>
        <div v-for="(q, index) in questions.coding" :key="index">
          <el-card class="question-card">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <h3>{{ q.description }}</h3>
              <el-tag v-if="q.score !== undefined" type="info" size="small">
                {{ q.score }} 分
              </el-tag>
            </div>
            <div v-html="q.description" />
            <el-button
              type="primary"
              @click="goToCoding(experimentId, q.id)"
              style="margin-top: 20px"
            >
              开始编程
            </el-button>
            <!-- 提交历史记录 -->
            <div v-if="q.submissions && q.submissions.length > 0" class="submission-history">
              <el-divider content-position="left">提交历史</el-divider>

              <!-- 最新提交结果摘要 -->
              <div class="latest-submission">
                <el-tag :type="getSubmissionStatus(q.submissions[0])">
                  最新: {{ q.submissions[0].passed }}/{{ q.submissions[0].total }} 通过
                </el-tag>
                <span class="submission-time">{{ formatTime(q.submissions[0].created_at) }}</span>
              </div>

              <!-- 历史提交列表 -->
              <el-collapse accordion>
                <el-collapse-item
                  v-for="(sub, subIndex) in q.submissions"
                  :key="subIndex"
                  :title="`提交记录 #${q.submissions.length - subIndex}`"
                >
                  <div class="submission-detail">
                    <div>
                      <el-tag :type="getSubmissionStatus(sub)">
                        {{ sub.passed }}/{{ sub.total }} 通过 ({{ calculatePercentage(sub) }}%)
                      </el-tag>
                      <span class="submission-time">{{ formatTime(sub.created_at) }}</span>
                    </div>
                    <div class="code-preview">
                      <el-tooltip content="点击查看完整代码" placement="top">
                        <el-button
                          size="small"
                          type="text"
                          @click="showCodePreview(q.id, subIndex, sub.code)"
                        >
                          查看代码
                        </el-button>
                      </el-tooltip>
                    </div>
                  </div>
                </el-collapse-item>
              </el-collapse>
            </div>

            <div v-else class="no-submissions">
              <el-tag type="info">暂无提交记录</el-tag>
            </div>
          </el-card>
        </div>
      </div>
    </div>

    <!-- 提交按钮 -->
    <div class="submit-section">
      <el-button
        type="primary"
        @click="showSubmitConfirm"
        :loading="submitting"
        :disabled="isDeadlinePassed"
      >
        {{ isDeadlinePassed ? '已过截止时间' : '提交实验' }}
      </el-button>
    </div>

    <!-- 提交确认对话框 -->
    <el-dialog
      v-model="submitDialogVisible"
      title="确认提交"
      width="30%"
    >
      <div class="submit-dialog-content">
        <p>当前完成进度：{{ totalCompleted }}/{{ totalQuestions }}</p>
        <el-alert
          v-if="hasUnansweredQuestions"
          type="warning"
          :closable="false"
          show-icon
        >
          还有未完成的题目，确定要提交吗？
        </el-alert>
        <el-alert
          v-if="isLateSubmission"
          type="warning"
          :closable="false"
          show-icon
        >
          已过截止时间，提交将扣除{{ experimentData.late_submission_penalty }}%分数
        </el-alert>
      </div>
      <p v-if="totalScore > 0" style="margin-top: 16px;">
      🎯 提交成功，总得分：<strong>{{ totalScore }}</strong> 分
      </p>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="submitDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmSubmit" :loading="submitting">
            确认提交
          </el-button>
        </span>
      </template>
    </el-dialog>


    <!-- 代码预览对话框 -->
    <el-dialog
      v-model="codePreviewVisible"
      :title="`代码预览 - ${currentQuestionTitle}`"
      width="80%"
    >
      <el-input v-model="previewedCode" type="textarea" :rows="20" readonly></el-input>
      <template #footer>
        <el-button type="primary" @click="codePreviewVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch, onUnmounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Check, Timer } from '@element-plus/icons-vue'
import axios from 'axios'
import { useExperimentProgressStore } from '@/stores/experimentProgress'
import { format } from 'date-fns'

const route = useRoute()
const router = useRouter()
const experimentProgressStore = useExperimentProgressStore()

const submitting = ref(false)
const submitDialogVisible = ref(false)
const experimentId = computed(() => Number(route.params.id))
const lastSaved = ref<string | null>(null)
const codePreviewVisible = ref(false)
const previewedCode = ref('')
const currentQuestionTitle = ref('')

const totalScore = ref(0)


// 添加实验数据响应式变量
const experimentData = ref({
  title: '',
  description: '',
  deadline: '',
  allow_late_submission: false,
  late_submission_penalty: 0
})

// 计算属性：是否已过截止时间
const isDeadlinePassed = computed(() => {
  if (!experimentData.value.deadline) return false
  return new Date() > new Date(experimentData.value.deadline)
})

// 计算属性：是否为迟交
const isLateSubmission = computed(() => {
  return isDeadlinePassed.value && experimentData.value.allow_late_submission
})
// 使用接口定义题目数据
interface QuestionOption {
  id: string
  text: string
}

interface QuestionChoice {
  id: number
  description: string
  options: QuestionOption[]
  selected: string
  isCorrect?: boolean
  correctAnswer?: string
}

interface QuestionFill {
  id: number
  description: string
  answer: string
  isCorrect?: boolean
  correctAnswer?: string
}

interface Submission {
  id: number
  passed: number
  total: number
  created_at: string
  code: string
}

interface QuestionCoding {
  id: number
  description: string
  submissions: Array<Submission>
  passed?: number
  total?: number
}

interface ExperimentQuestions {
  choice: QuestionChoice[]
  fill: QuestionFill[]
  coding: QuestionCoding[]
}

// 在接口定义部分添加后端返回的题目数据类型
interface ApiQuestionChoice {
  id: number
  description: string
  options: QuestionOption[]
}

interface ApiQuestionFill {
  id: number
  description: string
}

interface ApiQuestionCoding {
  id: number
  description: string
  submissions: Array<Submission>
  latest_status?: {
    passed: number
    total: number
  }
}

interface ApiExperimentData {
  choice: ApiQuestionChoice[]
  fill: ApiQuestionFill[]
  coding: ApiQuestionCoding[]
}

// 定义结果类型接口
interface ChoiceResult {
  question_id: number
  is_correct: boolean
  selected: string
  correct_answer: string
}

interface FillResult {
  question_id: number
  is_correct: boolean
  answer: string
  correct_answer: string
}

interface CodingResult {
  question_id: number
  passed: number
  total: number
}

interface SubmitResults {
  choice: ChoiceResult[]
  fill: FillResult[]
  coding: CodingResult[]
}

// 使用接口定义题目数据
const questions = ref<ExperimentQuestions>({
  choice: [],
  fill: [],
  coding: [],
})

// 计算各类题目的完成数量
const choiceCompleted = computed(() =>
  questions.value.choice.filter(q => q.selected).length
)

const fillCompleted = computed(() =>
  questions.value.fill.filter(q => q.answer).length
)

const codingCompleted = computed(() =>
  questions.value.coding.filter(q =>
    q.submissions && q.submissions.length > 0 &&
    q.submissions[0].passed === q.submissions[0].total
  ).length
)

// 计算总完成数和总题目数
const totalCompleted = computed(() =>
  choiceCompleted.value + fillCompleted.value + codingCompleted.value
)

const totalQuestions = computed(() =>
  questions.value.choice.length +
  questions.value.fill.length +
  questions.value.coding.length
)

// 检查每个部分是否完成
const isStepCompleted = (type: string) => {
  switch (type) {
    case 'choice':
      return questions.value.choice.length > 0 &&
             questions.value.choice.every(q => q.selected)
    case 'fill':
      return questions.value.fill.length > 0 &&
             questions.value.fill.every(q => q.answer)
    case 'coding':
      return questions.value.coding.length > 0 &&
             questions.value.coding.every(q =>
               q.submissions?.length > 0 &&
               q.submissions[0].passed === q.submissions[0].total
             )
    default:
      return false
  }
}

// 处理答案变化
const handleAnswerChange = (type: string, question: any) => {
  // 确保在下一个 tick 执行，避免可能的状态更新问题
  nextTick(() => {
    saveProgress()
  })
}

// 保存进度到 localStorage
const saveProgress = () => {
  const answers = {
    choice: Object.fromEntries(questions.value.choice.map(q => [q.id, q.selected])),
    fill: Object.fromEntries(questions.value.fill.map(q => [q.id, q.answer])),
    coding: Object.fromEntries(questions.value.coding.map(q => [q.id, q.submissions?.[0]?.code || '']))
  }

  lastSaved.value = new Date().toISOString()
  localStorage.setItem(
    'experiment-progress-' + experimentId.value,
    JSON.stringify({ answers, lastSaved: lastSaved.value })
  )
}

// 加载保存的进度
const loadSavedProgress = () => {
  const saved = localStorage.getItem('experiment-progress-' + experimentId.value)
  if (!saved) return
  const savedProgress = JSON.parse(saved)
  questions.value.choice.forEach(q => {
    if (savedProgress.answers.choice && q.id in savedProgress.answers.choice) {
      q.selected = savedProgress.answers.choice[q.id]
    }
  })

  questions.value.fill.forEach(q => {
    if (savedProgress.answers.fill && q.id in savedProgress.answers.fill) {
      q.answer = savedProgress.answers.fill[q.id]
    }
  })

  questions.value.coding.forEach(q => {
    if (savedProgress.answers.coding && q.id in savedProgress.answers.coding) {
      q.submissions = q.submissions || []
      q.submissions[0] = q.submissions[0] || {}
      q.submissions[0].code = savedProgress.answers.coding[q.id]
    }
  })

  lastSaved.value = savedProgress.lastSaved
}
const saveAutosave = () => {
  saveProgress()
}

// 获取实验题目数据
const fetchExperiment = async () => {
  try {
    const response = await axios.get<{ experiment: any; questions: any[] }>(`http://127.0.0.1:8000/api/experiments/experiments/${experimentId.value}/problems/`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      withCredentials: true
    });
    console.log('API响应数据:', response.data); // 调试日志
    // 验证数据结构
    if (!response.data?.questions) {
      throw new Error('API响应缺少questions字段');
    }

    // 保存实验基本信息
    experimentData.value = {
      title: response.data.experiment.title || '实验标题未定义',
      description: response.data.experiment.description || '暂无实验描述',
      deadline: response.data.experiment.deadline,
      allow_late_submission: response.data.experiment.allow_late_submission,
      late_submission_penalty: response.data.experiment.late_submission_penalty
    }
    // 按 type 分类题目
    const allQuestions = response.data.questions || [];

    questions.value = {
      choice: allQuestions
        .filter(q => q.type === 'choice')
        .map(q => ({
          id: q.id,
          description: q.title || '', // 确保 description 不为 undefined
          options: Array.isArray(q.options) ? q.options : [],
          selected: '',
          isCorrect: undefined,
          correctAnswer: undefined,
        })),
      fill: allQuestions
        .filter(q => q.type === 'blank')
        .map(q => ({
          id: q.id,
          description: q.title  || '', // 兼容两种字段名
          answer: '',
          isCorrect: undefined,
          correctAnswer: undefined,
        })),
      coding: allQuestions
        .filter(q => q.type === 'code')
        .map(q => ({
          id: q.id,
          description: q.description || q.title || '未命名编程题',
          submissions: Array.isArray(q.submissions) ? q.submissions : [],
          passed: (q.last_status || {}).passed || 0,
          total: (q.last_status || {}).total || 0
        }))
    };

    console.log('处理后的题目数据:', questions.value); // 调试日志

    // 继续加载保存进度等逻辑
    loadSavedProgress();
  } catch (error) {
      console.error('获取实验题目失败:', error);
      if (error.response) {
        if (error.response.status === 401) {
          ElMessage.error('认证失败，请重新登录');
          router.push('/login');
        } else if (error.response.status === 404) {
          ElMessage.error('实验不存在或已被删除');
        } else {
          ElMessage.error('获取实验题目失败: ' + (error.response.data.error || '服务器错误'));
        }
      } else {
        ElMessage.error('网络错误，请检查连接');
      }
  }
}

// 提交实验（原有的提交逻辑）
const submitExperiment = async () => {
  submitting.value = true;
  try {
    // 分别提取三种题型答案
    const answers = {
      choice: questions.value.choice.filter(q => q.selected).map(q => ({
        question_id: q.id,
        selected: q.selected
      })),
      fill: questions.value.fill.filter(q => q.answer).map(q => ({
        question_id: q.id,
        answer: q.answer
      })),
      coding: questions.value.coding.filter(q => q.submissions?.length > 0).map(q => ({
        question_id: q.id,
        code: q.submissions[0].code
      }))
    };

    if (
      answers.choice.length === 0 &&
      answers.fill.length === 0 &&
      answers.coding.length === 0
    ) {
      throw new Error('没有可提交的答案');
    }

    const response = await axios.post(
      'http://127.0.0.1:8000/submit/experiment/',
      {
        experiment_id: experimentId.value,
        answers
      },
      {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      }
    );

    const submissionId = response.data.submission_id;
    totalScore.value = response.data.total_score || 0;

    console.log('提交成功，submission_id:', submissionId);

    updateQuestionStatus(response.data.results);
    await fetchExperiment()

    ElMessage.success(`提交成功，得分：${totalScore.value} 分`);

    localStorage.removeItem('experiment-progress-' + experimentId.value);
  } catch (error) {
    console.error('提交过程中出错:', error);
    if (error.response) {
      console.error('错误详情:', error.response.data);
      ElMessage.error(
        `提交失败: ${error.response.data.detail || JSON.stringify(error.response.data)}`
      );
    } else {
      ElMessage.error(`提交错误: ${error.message}`);
    }
  } finally {
    submitting.value = false;
    submitDialogVisible.value = false;
  }
};



// 新增函数：更新题目状态
const updateQuestionStatus = (results: any) => {
  // 更新选择题状态
  if (results.choice) {
    questions.value.choice.forEach(q => {
      const result = results.choice.find((r: any) => r.question_id === q.id)
      if (result) {
        q.isCorrect = result.is_correct
        q.correctAnswer = result.correct_answer
      }
    })
  }

  // 更新填空题状态
  if (results.fill) {
    questions.value.fill.forEach(q => {
      const result = results.fill.find((r: any) => r.question_id === q.id)
      if (result) {
        q.isCorrect = result.is_correct
        q.correctAnswer = result.correct_answer
      }
    })
  }

  // 更新编程题状态
  if (results.coding) {
    questions.value.coding.forEach(q => {
      const result = results.coding.find((r: any) => r.question_id === q.id)
      if (result) {
        q.passed = result.passed
        q.total = result.total
      }
    })
  }
}

// 自动保存相关
let autoSaveInterval: number | undefined = undefined

onMounted(() => {
  fetchExperiment().then(() => {
    loadSavedProgress() // 确保加载保存的进度
    // 获取数据后立即执行一次保存
    saveProgress()
    // 设置定时保存（每分钟）
    autoSaveInterval = window.setInterval(saveProgress, 60000)
  })
})

onUnmounted(() => {
  if (autoSaveInterval) {
    clearInterval(autoSaveInterval)
  }
})

// 提交结果计算百分比
const calculatePercentage = (submission: Submission) => {
  if (submission.total === 0) return 0
  return Math.round((submission.passed / submission.total) * 100)
}

// 时间格式化
const formatTime = (timestamp: string) => {
  if (!timestamp) return ''
  return format(new Date(timestamp), 'yyyy-MM-dd HH:mm:ss')
}

// 获取提交状态标签类型
const getSubmissionStatus = (submission: Submission) => {
  if (submission.passed === submission.total) return 'success'
  if (submission.passed > 0) return 'warning'
  return 'danger'
}

// 显示代码预览
const showCodePreview = (questionId: number, submissionIndex: number, code: string) => {
  const question = questions.value.coding.find((q) => q.id === questionId)
  if (question) {
    currentQuestionTitle.value = `${question.id} - 提交 #${question.submissions.length - submissionIndex}`
    previewedCode.value = code
    codePreviewVisible.value = true
  }
}

// 跳转到编程题
const goToCoding = (experimentId: number, questionId: number) => {
  router.push({
    name: 'CodingTask',
    params: {
      id: experimentId.toString(),
      questionId: questionId.toString()
    },
    replace: true // 使用 replace 而不是 push，避免导航堆栈问题
  })
}

const showResults = (results: SubmitResults) => {
  // 更新选择题结果
  questions.value.choice.forEach((q) => {
    const result = results.choice.find((r) => r.question_id === q.id)
    if (result) {
      q.isCorrect = result.is_correct
      q.correctAnswer = result.correct_answer
    }
  })

  // 更新填空题结果
  questions.value.fill.forEach((q) => {
    const result = results.fill.find((r) => r.question_id === q.id)
    if (result) {
      q.isCorrect = result.is_correct
      q.correctAnswer = result.correct_answer
    }
  })

  // 更新编程题结果
  questions.value.coding.forEach((q) => {
    const result = results.coding.find((r) => r.question_id === q.id)
    if (result) {
      q.passed = result.passed
      q.total = result.total
    }
  })
}

// 添加新的计算属性
const hasUnansweredQuestions = computed(() => {
  return totalCompleted.value < totalQuestions.value
})

// 显示提交确认对话框
const showSubmitConfirm = () => {
  submitDialogVisible.value = true
}

// 确认提交
const confirmSubmit = async () => {
  submitDialogVisible.value = false
  await submitExperiment()
}
</script>

<style scoped>
.experiment-detail {
  padding: 16px;
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 64px; /* 减小顶部间距 */
}

.progress-wrapper {
  position: fixed;
  top: 0;
  left: 250px; /* 为左侧留出空间 */
  right: 0;
  z-index: 100;
  background-color: #f5f7fa;
  padding: 12px 24px;
  display: flex;
  justify-content: center;
}

.progress-indicator {
  width: calc(100% - 110px); /* 减去左侧空间的宽度 */
  max-width: 1080px; /* 适当减小最大宽度 */
  margin: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  background-color: #fff;
}

.progress-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  min-height: 48px;
}

.progress-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-main {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-main h2 {
  margin: 0;
  font-size: 16px;
  font-weight: 500;
  color: #409EFF;
}

.progress-tag {
  font-size: 13px;
  background-color: #ecf5ff;
  border-color: #d9ecff;
  color: #409eff;
  padding: 0 8px;
}

.progress-steps {
  display: flex;
  align-items: center;
  gap: 12px;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #909399;
}

.step-item.completed {
  color: #67c23a;
}

.step-title {
  font-size: 14px;
}

.step-tag {
  font-size: 12px;
  padding: 0 4px;
  height: 20px;
  line-height: 18px;
}

.step-divider {
  color: #dcdfe6;
  margin: 0 4px;
  font-size: 12px;
}

.last-saved {
  color: #909399;
  font-size: 13px;
}

/* 暗色主题支持 */
@media (prefers-color-scheme: dark) {
  .progress-wrapper {
    background-color: #141414;
  }

  .progress-indicator {
    background-color: #1a1a1a;
    border-color: #2c2c2c;
  }

  .progress-main h2 {
    color: #e5eaf3;
  }

  .step-item {
    color: #a3a6ad;
  }

  .step-divider {
    color: #4c4d4f;
  }

  .step-item.completed {
    color: #85ce61;
  }
}

.questions-container {
  width: 100%;
}

.question-section {
  margin-bottom: 40px;
}

.question-card {
  margin: 16px 0;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.question-card:hover {
  transform: translateY(-2px);
}

.submit-section {
  text-align: center;
  margin-top: 40px;
  margin-bottom: 40px;
}

.result-indicator {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.correct-answer {
  margin-left: 16px;
  color: #f56c6c;
}

.submit-dialog-content {
  text-align: center;
  padding: 20px 0;
}

.submission-history {
  margin-top: 20px;
}

.latest-submission {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.submission-time {
  margin-left: 15px;
  font-size: 0.85em;
  color: #909399;
}

.submission-detail {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px 0;
}

.code-preview {
  margin-left: 15px;
}
</style>
