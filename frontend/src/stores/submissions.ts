import { defineStore } from 'pinia'
import axios from 'axios'
import { ref } from 'vue'
import { useAuthStore } from './authStore'

interface CodingSummary {
  passedCount: number
  totalCount: number
}

interface Submission {
  id: number
  studentId: number
  studentName: string
  setId: number
  setTitle: string
  deadline: string
  submittedAt: string
  passed: boolean
  answers: any[]
  codingSummary?: CodingSummary | null
}

export const useSubmissionStore = defineStore('submissions', () => {
  const submissions = ref<Submission[]>([])

  const fetchSubmissions = async () => {
    try {
      const authStore = useAuthStore()
      const res = await axios.get('http://127.0.0.1:8000/api/experiments/submissions/', {
        headers: authStore.token ? {
          Authorization: `Bearer ${authStore.token}`,
        } : undefined,
      })
      submissions.value = res.data
    } catch (err) {
      console.error('获取提交记录失败', err)
    }
  }

  return { submissions, fetchSubmissions }
})
