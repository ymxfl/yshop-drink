/**
 * 分包内防抖，避免引用 uni_modules 导致主包打入 debounce.js
 */
function debounce(func, wait = 500, immediate = false) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      timeout = null
      if (!immediate) func.apply(this, args)
    }
    const callNow = immediate && !timeout
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
    if (callNow) func.apply(this, args)
  }
}

export default debounce
