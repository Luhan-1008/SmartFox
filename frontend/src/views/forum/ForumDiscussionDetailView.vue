<template>
  <div class="discussion-detail" v-loading="loading">
    <el-card v-if="post" class="post-card">
      <template #header>
        <div class="post-header">
          <div>
            <h2>{{ post.title }}</h2>
            <p class="meta">
              <span>作者：{{ post.author }}</span>
              <span>发布时间：{{ formatTime(post.createTime) }}</span>
            </p>
          </div>
          <el-tag :type="post.isLiked ? 'primary' : 'info'">点赞 {{ post.likes }}</el-tag>
        </div>
      </template>

      <div class="post-content">
        <p>{{ post.content }}</p>
      </div>
    </el-card>

    <el-empty v-else description="未找到该讨论帖" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import dayjs from 'dayjs'
import { useDiscussionStore } from '@/stores/discussion'

const route = useRoute()
const store = useDiscussionStore()
const loading = ref(false)

const postId = computed(() => Number(route.params.id))
const post = computed(() => store.posts.find(item => item.id === postId.value))

const formatTime = (time: string) => {
  return dayjs(time).format('YYYY-MM-DD HH:mm')
}
</script>

<style scoped>
.discussion-detail {
  max-width: 960px;
  margin: 0 auto;
  padding: 20px;
}

.post-card {
  border-radius: 12px;
}

.post-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.meta {
  display: flex;
  gap: 16px;
  margin: 8px 0 0;
  color: #909399;
  font-size: 14px;
}

.post-content {
  line-height: 1.8;
  color: #303133;
  white-space: pre-wrap;
}
</style>
